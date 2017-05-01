=======================
Un bot IRC pour tweeter
=======================

:date: 2015-01-04 11:28:40
:category: imported
:slug: un-bot-irc-pour-tweeter
:authors: matael
:summary: Utiliser de Net Twitter et Bot BasicBot pour tweeter
:tags: perl,irc,bot,twitter

Alors que le HAUM_ vient de naître à proprement parler, les besoins de communiquer se sont fait sentir.

De leur côté, les gars de LinuXMaine_ ont créé un bout de wiki pour le tout nouveau hackerspace, un GoogleGroup (*sic*)
a permis de relier tout le monde par mail et enfin, un *chan* IRC a été mis en place.

L'idée de départ
================

Finalement, l'idée de filer à tout le monde le mot de passe du compte twitter pour le HAUM me posait un léger soucis :

- risque de *leak* du mot de passe
- problème de personne qui change le mot de passe
- etc...

L'idée était donc de créer un bot qui vive sur le chan IRC du HAUM et qui permette aux gens de *tweeter* au nom du
hackerspace. Enfin, il devait permettre de gérer facilement la liste des gens autorisés à poster et récuperer les
*mentions* pour les afficher sur le *chan*.

L'organisation du code
======================

Pour que le bot soit le plus hackable possible, j'ai choisi de faire un module Perl complet.

Le fichier ressemble donc à :

.. sourcecode:: perl

    package TwitterBot;

        # import des modules

        # pour que le package soit un bot
        use base qw( Bot::BasicBot );

        # instructions...

    1;

Les modules
===========

Plusieurs modules sont nécessaires pour ce bot, voilà les premières lignes du code (que vous pourrez aussi trouver sur
un `dépot github`_) :

.. sourcecode:: perl

    # classique
    use strict;
    use warnings;
    use 5.010;

    # pour raccourcir les liens (cf le bonus ;))`
    use LWP::UserAgent;

    # autres
    use Bot::BasicBot;  # c'est un bot IRC
    use Net::Twitter;   # on a besoin de discuter avec l'API Twitter
    use Redis; 			# pour gérer les permissions

Les commentaires sont modifiés pour les besoins de l'article.

Plusieurs précisions :

- même si ce n'est pas forcément la meilleure manière de faire, j'utilise Redis pour gérer les permissions parce que
  c'est globalement simple d'aller les modifier "à la main" (si le bot foire)
- j'utilise le bout de code donné par http://ln-s.net pour raccourcir les liens, d'où l'utilisation de ``LWP``

Le code lui-même
================

Le code peut se découper en 3 parties :

- l'envoi d'un *tweet*
- la gestion des permissions
- la réduction des liens (aka, le bonus ;))
- la récupération des *mentions*

On va les voir les unes après les autres.

Pour la gestion des messages qui arrivent, on définira la fonction ``said()``, comme le veux ``Bot::BasicBot`` :

.. sourcecode:: perl

    sub said {
        my ($self, $msg) = @_;

        # twitter link
        my $twlk = Net::Twitter->new(
            traits   => [qw/OAuth API::REST/],
            consumer_key        => $self->{consumer_key},
            consumer_secret     => $self->{consumer_secret},
            access_token        => $self->{token},
            access_token_secret => $self->{token_secret}
        );

        # redis link
        my $redis_db = $self->{redis_db};
        my $redis_pref = $self->{redis_pref};
        my $master = $self->{master};

        my $rdb = Redis->new();
        $rdb->select($redis_db);


        # faire des trucs ici

    }


Envoi d'un *tweet*
------------------

Pour envoyer un *tweet*, j'ai décidé de définir la commande ``@tweet truc à twitter`` dans le bot.

L'idée est simple :

#. on détecte la commande
#. on vérifie si la personne a le droit de poster
#. on vérifie que le futur *tweet* n'excède pas 140 caractères
#. on envoie le tweet
#. on affiche que tout s'est bien passé

La gestion des erreurs n'a pas été prise en compte : il n'y en a pas vraiment besoin ici.

C'est parti pour le code :

.. sourcecode:: perl

    # si le message est de la forme /^@tweet un truc derrière$/...
    # (on retient le truc derrière dans $1
	if ($msg->{body} =~ /^\@tweet (.+)$/) {

        # on vérifie si le poster est bien dans la DB des personnes autorisées
		if ($rdb->get($redis_pref.$msg->{who})) {

            # on vérifie que la longueur n'excède pas 140cars.
			if (length($1) > 140) {

                # si c'est le cas, on le dit sur le chan et on affiche le nombre
                # de cars. du message.
				$self->say(
					who => $msg->{who},
					channel => $msg->{channel},
					body => "Un peu long, ".length($1)." au lieu de 140..."
				);

                # on quitte alors la fonction
				return;
			}

			# mettre à jour le compte twitter...
			$twlk->update($1);
			$self->say(
				who => $msg->{who},
				channel => $msg->{channel},
				body => "C'est parti !"
			);
			return;

		# Si le posteur n'est pas dans les nicks autorisés
		} else {
            #... on lui dit
			$self->say(
				who => $msg->{who},
				channel => $msg->{channel},
				body => "On se connait ?"
			);
			return;
		}
	}

Voilà pour ce qui permet de *tweeter*.

Gestion des permissions
-----------------------

L'idée, c'est que le *"maître"* du bot soit capable d'ajouter ou de supprimer des gens d'une liste de posteurs
"autorisés". Il faut que cette liste perdure même si le bot s'arrête.

Bien sûr, j'aurais pu utiliser ``Storable`` ou un truc du genre (JSON ou YAML par exemple). J'ai choisi Redis parce que
j'ai un serveur Redis qui tourne et que je pourrais toujours conserver ma liste si je recode le bot en python par
exemple.

Finalement, j'aime pas toucher à des fichiers pour si peu et, comme utiliser Redis ne me demandait pas d'effort
particulier, j'ai pris ce que j'avais sous la main.

Le code est relativement simple :

.. sourcecode:: perl

	# ajouter quelqu'un aux nicks autorisés
    # commande : @allow nick
	if (($msg->{who} eq $master) and $msg->{body} =~ /\@allow (\w+)/) {

        # on ajoute le nick à la liste Redis
		$rdb->set($redis_pref.':'.$1, 1);

        # on dit que tout va bien (parce que tout va toujours bien)
		$self->say(
			who => $master,
			channel => $msg->{channel},
			body => "Ok ! $1 est maintenant dans la liste des twolls potentiels :3"
		);
	}

	# supprimer un nick de la liste
    # commande : @disallow nick
	if (($msg->{who} eq $master) and $msg->{body} =~ /\@disallow (\w+)/) {

        # on le supprime (s'il existait (pour éviter les erreurs, on vérifie)
		$rdb->del($redis_pref.':'.$1) if $rdb->get($redis_pref.$1);

        # on dit que tout va bien ;)
		$self->say(
			who => $master,
			channel => $msg->{channel},
			body => "Adieu $1, je l'aimais bien"
		);
	}

Et plouf ! Ça, c'est fait.

Réduire les liens
=================

Je vous met le bout de code tel quel mais il vient tout droit de http://ln-s.net :

.. sourcecode:: perl

	# shrink links
	# partly form ln-s.net ;) thanks to them
	if ($msg->{body} =~ /^\@shrink (.+)$/) {
		if ($rdb->get($redis_pref.':'.$msg->{who})) {
			# set up the LWP User Agent and create the request
			my $userAgent = new LWP::UserAgent;
			my $request = new HTTP::Request POST => 'http://ln-s.net/home/api.jsp';
			$request->content_type('application/x-www-form-urlencoded');

			# encode the URL and add it to the url parameter in the request
			my $url = $1;
			$url = URI::Escape::uri_escape($url);
			$request->content("url=$url");

			# make the request
			my $response = $userAgent->request($request);

			# handle the response
			if ($response->is_success) {
				my $reply = $response->content;
				1 while(chomp($reply));
				my ($status, $message) = split(/ /,$reply, 2);
				$self->say(
					who => $msg->{who},
					channel => $msg->{channel},
					body => $message
				);
			} else {
				my ($status, $message) = split(/ /,$response->status_line, 2);
				$self->say(
					who => $msg->{who},
					channel => $msg->{channel},
					body => "Erf... Statut : $status => $message"
				);
			}
			return;

		} else {
			$self->say(
				who => $msg->{who},
				channel => $msg->{channel},
				body => "On se connait ?"
			);
			return;
		}
	}

Récupérer les *mentions*
------------------------

L'idée là encore c'est que tout le monde puisse voir les mentions qui arrivent.

Vous allez voir, c'est trivial.
Le seul petit point vicieux, c'est qu'il faut retenir l'**ID** de la dernière *mention*.

On utilise la fonction ``tick()`` de ``Bot::BasicBot`` qui permet d'éxécuter une action périodiquement. Le temps (en
secondes) entre deux "tick" est donné par le nombre de retour de la fonction.

Le code se comprend bien une fois commenté :

.. sourcecode:: perl

    # on vérifie twitter toutes les 5 minutes pour ne pas surcharger l'API
    sub tick {
        my ($self) = @_;

        # twitter link
        my $twlk = Net::Twitter->new(
            traits   => [qw/OAuth API::REST/],
            consumer_key        => $self->{consumer_key},
            consumer_secret     => $self->{consumer_secret},
            access_token        => $self->{token},
            access_token_secret => $self->{token_secret}
        );

        # redis link
        my $redis_db = $self->{redis_db};
        my $redis_pref = $self->{redis_pref};
        my $master = $self->{master};

        my $rdb = Redis->new();
        $rdb->select($redis_db);

        # récupérer l'ID du dernier tweet
        my $last = $rdb->get($redis_pref.":last_twid");
        my @statuses;

        if (!$last) {
            # si on en trouve pas, on récupère tout (et on laissse l'API gérer)
            @statuses = @{$twlk->mentions()};
        } else {
            # sinon, on utilise le paramètre since_id de
            # Net::Twitter->mention() pour filtrer
            @statuses = @{$twlk->mentions({since_id => $last})};
        }


        # On envoie chaque tweet sur le canal
        # y'a un offset de 1 pour ne pas tomber dans les limites
        # des valeurs de retour de l'API twitter
        my $len = scalar(@statuses);
        if ($len > 1) {
            my $status;
            my $i = 1;
            while ($i < $len) {
                $self->say(
                        channel => $self->{channels}->[0],
                        body => $statuses[$len-$i]->{user}->{screen_name}.
                            " => ".$statuses[$len-$i]->{text}
                );
                $i++;
            }

            $rdb->set($redis_pref.":last_twid", $statuses[$len+1-$i]->{id});
        }

        # "dormir" 5 min ;)
        return 5*60;
    }

Et voilà pour ça !

En fait, ça produit un retour de la forme :

    celui qui a twitté => le tweet lui même

Conclusion
==========

L'idée derrière cet artcile n'était pas de faire un tuto complet mais plutôt de dérouler un peu le code d'un bot
permettant de lier twitter et IRC. Il en existe des dixaines d'autres.

Il y avait forcément d'autres moyens de le faire (vous vous souvenez ? **TIMTOWTDI**), des plus propres, des plus
efficaces, des moins beaux, etc...

L'objectif, c'était clairement de fournir un programme pour combler un besoin. Il ne fallait pas forcément que ça soit
beau, mais seulement que ça marche.

Hackez ça comme vous le voudrez ! (**WTFPL ftw !**).

.. _HAUM: http://twitter.com/haum72
.. _LinuXMaine: http://linuxmaine.org
.. _dépot github: https://github.com/haum/TwitterBot
