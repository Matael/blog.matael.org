==============================
Les bases des Bots IRC en perl
==============================

:date: 2015-01-04 11:28:38
:slug: les-bases-des-bots-irc-en-perl
:authors: matael
:summary: Exemple a travers l'écriture d'un mini-bot
:tags: perl, irc, imported

IRC_ est un réseau de chat bien connu et de nombreux bots (et utilisateurs standards d'ailleurs) y rodent.
Il existe énormément de manières et de moyens d'écrire un bot pour IRC et ce dans quasiment tous les langages.

Ici, nous allons nous intéresser à l'écriture d'un bot simple en perl à l'aide du module ``Bot::BasicBot``.

Bot::BasicBot
=============

Installation
------------

Pour installer ce magnifique module, deux options : soit vous avez configuré ``CPAN.pm`` et vous pourrez utiliser :

.. code-block:: bash

    sudo cpan Bot::BasicBot

Soit vous ne l'avez pas configuré et vous préferez passer par cpanminus_ :

.. code-block:: bash

    curl -L http://cpanmin.us | perl - --sudo Bot::BasicBot

voire même sans ``curl`` et en utilisant ``wget`` :

.. code-block:: bash

    wget -O - http://cpanmin.us | perl - --sudo Bot::BasicBot


Présentation (rapide)
---------------------

``Bot::BasicBot`` est un module plutot complet qui permet d'écrire facilement des bots IRC en utilisant la programmation évenementielle.

Celui-ci contient une classe dont le bot héritera et pour la personnalisation des actions, nous surchargerons certaines méthodes.

Bot pour absents
================

Notre objectif sera d'écrire un bot très simple qui devra signaler aux utilisateurs que son maître n'est pas là.

Il agira :

- quand un utilisateur se connecte (en lui disant que son maître est absent)
- quand un utilisateur cite le nom de son maître (hl), dans une action ou un message classique

La documentation_ du module nous indique les méthodes à surcharger :

- ``chanjoin()`` pour la connexion
- ``said()`` pour les messages classique
- ``emoted()`` pour les *actions*

Notons que c'est la méthode ``say()`` qui permet d'émettre un message.

La base
-------

Commençons par écrire la base de notre bot :

.. code-block:: perl

    #!/usr/bin/env perl

    use strict;
    use warnings;
    use Bot::BasicBot;

    package BotPasLa;
    use base qw( Bot::BasicBot );

    sub said {
        my ($self, $msg) = @_;

        # ... action si HL par message normal
    }

    sub emoted {
        my ($self, $msg_hl) = @_;

        # ... action si HL par "action"
    }

    sub chanjoin {
        my ($self, $msg) = @_;

        # ... action si connexion d'un user
    }
    1;

Rien de bien compliqué ici.

Il faut juste savoir qu'en Perl, les arguments sont passés aux fonctions via le tableau spécial : ``@_``.

Lorsque l'on veut passer des tableaux ou des dictionnaires (*hashes*), on passe en fait une référence (scalaire) vers la structure voulue.

Ici, ``$self`` est une référence vers l'objet (instance) lui-même et ``$msg`` est une référence vers un *hash* contenant les infos relative au "message" reçu.

Et si on le faisait paramétrable ?
----------------------------------

Ce qui est paramétrable (dans la mesure du raisonnable) est mieux, aussi essayons de faire en sorte que ce bot soit paramétrable à l'instanciation.

On va définir des attributs :

- ``$master`` : pseudo du maître du bot
- ``$hl_regexp`` : regex pour détecter le HL
- ``$msg_join`` : message à afficher quand un utilisateur se connecte
- ``$msg_hl`` : message à afficher après un HL du maître

Nous pourrons utiliser ces attributs dans le code du bot.

D'ailleurs, écrivons le ;)

``said()`` et ``emoted()``
--------------------------

Ces fonctions font, pour ainsi dire la même chose : elles vérifient que le corps (``$msg->{body}``) correspond à la regex ``$hl_regexp``.

Si celle ci *matche*, alors on affiche le message correspondant ``$msg_hl`` en l'adressant à l'utilisateur ayant parlé.

Par exemple, pour ``said()``:

.. code-block:: perl
    
    sub said {
        my ($self, $msg) = @_;

        if ($msg->{body} =~ $self->{hl_regexp}) {
            $self->say(
                who=>$msg->{who},
                channel=>$msg->{channel},
                body=>$self->{msg_hl},
            );
        }
    }

Pour ``emoted()``, étant donné que les arguments qui lui sont passés sont les mêmes, la fonction est la même, à l'exception du nom.

Il aurait été possible d'écrire une seule fois la fonction (pour ``said()`` par exemple) et de l'appeller dans l'autre.

``chanjoin()``
--------------

Enfin, la fonction ``chanjoin()`` devra  vérifier qu'il ne va pas avertir son propre maître qu'il n'est pas là (ce serait particulièrement stupide) et qu'il ne va pas s'avertir lui même en lisant son propre message de connexion.

Ça donne quelque chose comme ça :

.. code-block:: perl
    
    sub chanjoin {
        my ($self, $msg) = @_;

        if ($msg->{who} ne $self->{master} and $msg->{who} ne $self->{nick}) {
            $self->say(
                who=>$msg->{who},
                channel=>$msg->{channel},
                body=>$self->{msg_join},
            );
        }
    }

Là encore, un ``say()`` sous conditionnelle.
Pour tester la différence de deux chaînes en Perl, on utilise ``ne`` et non ``!=``.

Assemblage
----------

Reste assembler tout ça et a instancier puis lancer le bot via son constructeur ``new()`` et sa méthode ``run()`` (définis par ``Bot::BasicBot``).

.. code-block:: perl

    #!/usr/bin/env perl

    use strict;
    use warnings;
    use Bot::BasicBot;

    package BotPasLa;
    use base qw( Bot::BasicBot );

    sub said {
        my ($self, $msg) = @_;

        if ($msg->{body} =~ $self->{hl_regexp}) {
            $self->say(
                who=>$msg->{who},
                channel=>$msg->{channel},
                body=>$self->{msg_hl},
            );
        }
    }

    sub emoted {
        my ($self, $msg_hl) = @_;

        if ($msg->{body} =~ $self->{hl_regexp}) {
            $self->say(
                who=>$msg->{who},
                channel=>$msg->{channel},
                body=>$self->{msg_hl},
            );
        }
    }

    sub chanjoin {
        my ($self, $msg) = @_;

        if ($msg->{who} ne $self->{master} and $msg->{who} ne $self->{nick}) {
            $self->say(
                who=>$msg->{who},
                channel=>$msg->{channel},
                body=>$self->{msg_join},
            );
        }
    }
    1;


    my $bot = BotPasLa->new(
        server => "irc.freenode.org",
        channels => ["#test_chan"],
        nick => 'pala',
        charset=> "utf-8",
        master=>"matael",
        hl_regexp=>qr/.*matael\W.*/,
        msg_join=>"matael est pas lesa ;)",
        msg_hl=>"Pas la peine de le HL, il est pas la ;)"
    )->run();

Lancement
---------

Le *shebang* nous permet, une fois rendu exécutable, de lancer le script ainsi (nous admettrons qu'il s'appelle ``pala.pl``):

.. code-block:: bash

    ./pala.pl

Sinon, sachez qu'on peut le lancer de manière classique avec :

.. code-block:: bash

    perl pala.pl


Conclusion
==========

Bien que très simple, ce bot montre comment utiliser la classe fournie par ``Bot::BasicBot``.

Notez qu'on peut parfaire ledit bot en retenant par exemple la liste des HL et en les transmettant au maître à son retour.
On peut aussi les lui transférer par mail, mais ce n'est pas l'objet de cet article.


.. _IRC: http://fr.wikipedia.org/wiki/Internet_Relay_Chat
.. _cpanminus: https://raw.github.com/miyagawa/cpanminus/master/cpanm
.. _documentation: http://search.cpan.org/~hinrik/Bot-BasicBot-0.89/lib/Bot/BasicBot.pm
