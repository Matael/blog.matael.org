===============
Quand MPD danse
===============

:date: 2015-01-04 11:28:39
:slug: quand-mpd-danse
:authors: matael
:summary: Interface vers MPD via HTTP et mise en oeuvre android via SL4A
:tags: python, perl, android, imported

Il a peu, j'ai découvert l'existence de Dancer_, un micro-framework web pour **perl**.

J'ai appris à m'en servir sommairement et en ai profité pour bidouiller une interface vers une instance d'ADECampus en
guise de pied de nez à ceux qui pensaient que ça pouvait pas se faire sans module (payant).

Aujourd'hui, je réutilise un peu ce truc dans le but de réaliser une télécommande pour MPD_.

Quelques infos
==============

Pour ce qui du système, je tourne sous ArchLinux_ (à jour forcément) avec **perl 5.16.1** et **MPD 0.17.1**.

.. image:: /static/images/mpd/shot.png
    :align: right

Le téléphone Android qui servira de télécommande dans la suite est un Samsung i5700 (*Galaxy Spica*) rooté avec SL4A_
d'installé (pas à jour je pense), c'est toutefois largement suffisant pour ce que l'on veut en faire.

Objectifs
=========

On va commencer par comprendre comment s'interfacer avec MPD depuis un script perl, ensuite, nous passerons à l'écriture
du micro-serveur pour le controle d'MPD_.

Finalement, on regardera de plus près comment utiliser SL4A_ (*Scripting Layer For Android*) pour le code de la
télécommande elle même (voir *screenshot* ci-contre).

L'objectif profond n'est **pas** de fournir une solution parfaite mais une piste. C'est typiquement un *proof of
concept* qui gagnerait à être amélioré mais qui fonctionne ainsi.

Perl The Dancer
===============

Pour la partie tournant sur la machine hôte, on se contentera d'un petit script Perl utilisant Dancer_ pour la partie
web et `Net::Telnet`_ pour l'interfaçage avec mpd.

Vous pourrez installer les deux modules via CPAN.

Le squelette du script ressemblera donc à :

.. sourcecode:: perl

    use strict;
    use warnings;
    use Dancer;
    use Net::Telnet;

    # global params
    set 'warning' 		=> 1;
    set 'startup_info'  => 1;
    set 'show_errors' 	=> 1;
    set 'logger' 		=> 'console';
    set 'log' 			=> 'debug';

    # ... faites un truc ici ..

    dance;

J'en profite pour préciser que Dancer_ admet des paramètres globaux via la construction :

.. sourcecode:: perl

    set 'param_name' => value;

C'est souvent le cas dans ce genre de micro-framework et peu s'avérer *très* pratique..

Les commandes de MPD
--------------------

Par défaut, MPD écoute sur ``0.0.0.0:6600`` il s'agit d'une socket telnet classique à laquelle on peut se connecter sans
soucis depuis un client telnet.

Il semble que le daemon accepte toute une série de commandes pour la configuration et les changements d'états. Voilà les
plus courantes :

play
	démarrer la lecture
stop
	arrêter la lecture
pause
	mettre en pause, sortir de la pose
previous
	passer à la plage précédente
next
	passer à la plage suivante

Et d'autre que nous n'utiliserons pas cette fois :

currentsong
	Affiche des infos sur la plage en cours
state
	Affiche des infos sur le serveur mpd

Normalement, MPD renvoie soit les informations demandées, soit ``OK MPD <version>``, soit ``ACK [5@0] {} unknown command
"<la_commande>"``.

Et avec Perl
~~~~~~~~~~~~

Avec Perl, on va utiliser le module ``Net::Telnet``. Pour simplifier le code des vues ensuite, on va écrire une fonction
qui prend une commande MPD_ en paramètre, se connecte *via* telnet à MPD, lui envoie la commande, récupère le résultat
et se déconnecte en renvoyant le résultat à l'appellant.

Le code de cette fonction n'est pas compliqué, il est tiré principalement de la doc de ``Net::Telnet`` :

.. sourcecode:: perl

    sub send_command {
        my ($command) = @_;             # récup de l'argument
        my $conn = new Net::Telnet;     # création de l'instance telnet
        $conn->open(                    # connexion
            host => "localhost",
            port => 6600
        );
        $conn->print($command);         # envoi de la commande
        my $result = $conn->getline;    # récup. du résultat
        $conn->close;                   # fermeture de la connexion
        return $result;
    }

La capacité de Perl à accepter l'omission de parenthèse permet, dans la plupart des cas d'obtenir un code beaucoup plus
propre (même si souvent cryptique).

La structure d'une vue
----------------------

Avec Dancer_, pour répondre à une ``GET`` sur une URL on écrit :

.. sourcecode:: perl

    get $url => sub {
        # do something
    }

Ainsi, pour répondre *"Hello World"* quand une requête arrive sur "/yop", on fera :

.. sourcecode:: perl

    get "/yop" => sub {
        return "Hello World"
    }

Maintenant, on va écrire les 5 fonctions pour les 5 commandes de la première partie de tout à l'heure en utilisant la
fonction que nous avons écrit pour et en renvoyant le résultat :

.. sourcecode:: perl

    # play/pause/stop
    get "/play"		=> sub { return send_command('play');	  };
    get "/pause"	=> sub { return send_command('pause');	  };
    get "/stop"		=> sub { return send_command('stop');	  };

    # prev/next
    get "/previous"	=> sub { return send_command('previous'); };
    get "/next"		=> sub { return send_command('next');	  };

On aurait aussi pu le faire en une fois et à grand renforts de *regexes*.

Lancement
---------

Le script complet (nommé ``serv.pl`` par exemple) ressemble à ça :

.. sourcecode:: perl

    use strict;
    use warnings;
    use Dancer;
    use Net::Telnet;

    # global params
    set 'warning' 		=> 1;
    set 'startup_info'  => 1;
    set 'show_errors' 	=> 1;
    set 'logger' 		=> 'console';
    set 'log' 			=> 'debug';

    sub send_command {
        my ($command) = @_;
        my $conn = new Net::Telnet;
        $conn->open(
            Host => "localhost",
            Port => 6600
        );
        $conn->print($command);
        my $result = $conn->getline;
        $conn->close;
        return $result;
    }

    # play/pause/stop
    get "/play"		=> sub { return send_command('play');	  };
    get "/pause"	=> sub { return send_command('pause');	  };
    get "/stop"		=> sub { return send_command('stop');	  };

    # prev/next
    get "/previous"	=> sub { return send_command('previous'); };
    get "/next"		=> sub { return send_command('next');	  };

    dance;

Et il se lance comme tout script perl :

.. sourcecode:: bash

    $ perl serv.pl
    $ perl serv.pl& # arrière plan

Android
=======

SL4A et python
--------------

Depuis le site de SL4A_, vous pourrez télécharger l'application et l'interpréteur python, c'est tout ce dont nous aurons
besoin.


L'interprèteur python est fourni avec ``urllib2``, soit tout ce qu'il nous faut pour communiquer avec la machine hôte.
Enfin, l'API d'Android nous permettra parfaitement de créer un menu comme celui montré en début d'article.

Pour le reste, le code de l'UI android est tiré des exemples de la doc d'SL4A_ (exemple ``uilist.py``), rien de compliqué :

.. sourcecode:: python

    import android  # lib android
    import urllib2  # requetes http
    import sys      # pour exit()

    # on initialise l'API
    droid = android.Android()

    # IP de la machine hote et port
    HOST = '192.168.1.14'
    PORT = 3000

    # Choix de l'action
    def getaction():
        "get user action"

        # on initialise la boite de dialogue avec son titre
        droid.dialogCreateAlert("MPD Remote Controler")

        # on envoie les items
        droid.dialogSetItems([
            "Start",
            "Pause",
            "Stop",
            "Previous",
            "Next"])

        # on affiche
        droid.dialogShow()

        # on récupère le résultat
        result = droid.dialogGetResponse().result

        # si un item à été choisi, on le renvoie,
        # sinon, on met -1
        if result.has_key("item"):
            return result["item"]
        else:
            return -1

    # On récupère l'action à faire
    action = getaction()

    # On vérifie que ce n'est pas -1
    # et si besoin on averti l'utilisateur
    if action < 0:
        droid.makeToast("no item chosen")
        droid.close()
        sys.exit()

    # On remet les bon noms (pour les urls)
    real_acts = [
        'start',
        'pause',
        'stop',
        'previous',
        'next'
    ]

    # on balance la requète et on récupère le résultat pour l'afficher
    result = urllib2.urlopen("http://{0}:{1}/{2}".format(
        HOST,
        PORT,
        real_acts[action])
    )

    # on affiche
    toast = '\n'.join(result.readlines())
    droid.makeToast(toast.rstrip())

    # on quitte
    droid.close()
    sys.exit()

Voilà donc ledit code, finalement assez simple.

Je ne m'attarderais pas dessus. Retenez simplement que SL4A_ est un excellent moyen de scripter de petits utilitaires
pour Android.

Désormais, si le serveur est lancé, vous pourrez contrôler MPD_ depuis votre téléphone Android, ce qui est (avouons le)
bien symmpathique.

Conclusion
==========

Cet article a donc présenté succintement une interface pour MPD_ pas forcément très connue.

Nous avons aussi pu toucher à Dancer_ et `Net::Telnet`_ qui permettent d'écrire facilement une passerelle web vers MPD.

Enfin, le script final montre un moyen alternatif de créer de petites applications facilement incluables dans Android.

La piste SL4A_ est à creuser pour d'autres projets et deviendra peut être une constante chez moi pour les projets
demandant une interface mobile rapidement développée.

.. _Dancer: http://perldancer.org
.. _MPD: http://fr.wikipedia.org/wiki/Music_Player_Daemon
.. _ArchLinux: http://archlinux.org
.. _SL4A: http://code.google.com/p/android-scripting/
.. _`Net::Telnet`: http://search.cpan.org/~jrogers/Net-Telnet-3.03/lib/Net/Telnet.pm
