==============
Arduino et DMX
==============

:date: 2015-01-04 11:28:39
:slug: arduino-et-dmx
:authors: matael
:summary: Un driver minimaliste et un arduino pour commander un projecteur
:tags: arduino, dmx, imported

Entrant dans un nouvel appartement, je me suis dit que créer une ambiance sympa avec de la lumière pouvait être une
bonne idée.

L'opportunité s'est présentée quand j'ai pu m'acheter un PAR 56 Led. Comme la majorité des projecteur de ce type, le PAR
Led est muni d'un récepteur DMX et peut donc être assigné directement.

L'avant dernière étape était de pouvoir contrôler la bête par via l'Arduino (la dernière étant de le faire via mon
téléphone Android).

    Je dis merci à `@jblb_72` pour son coup de main.

DMX ?
=====

Dafuq iz dat ?
--------------

DMX (DMX512 en fait) signifie *Digital MultipleX 512*. C'est un standard de communication pour le contrôle d'équipements
scéniques.
Il est à ce titre utilisé pour contrôler des projecteurs et autres effets lors de concerts (ça tombe bien, c'est ce que
l'on veut faire, au concert près).

Le DMX repose sur les mêmes bases physiques que la RS485 et les drivers pour ce standard peuvent aussi servir pour du
DMX.

Notez que le DMX est habituellement utilisé via une transmission filaire à 5 points (dont sont deux peu voire pas
utilisés) ou 3 points.

Plus récemment, on a vu des signaux DMX passer par des cables RJ-45 (ethernet) voire carrément sans fil (voir le projet
`DMX WithOut Wire`_ ou bien même Art-Net_).
De mon point de vue, le transfert sans fil de trames DMX est un simple problème d'encapsulation. Si certains pensent que
j'ai tort, qu'il me le disent : j'apprendrais un truc \\o/ !

Le DMX fonctionne par trames de 512 canaux (1 octet par canal) à une fréquence de 44Hz.
Concrètement, ça signifie que 44 fois par seconde, une trame est envoyée, contenant l'information de chacun des 512
canaux d'un octet (de ``0x00`` à ``0xFF``).

Le rôle du maître (*master*) est d'envoyer les trames.

Le DMX n'est pas full-duplex, les transmissions se font d'un maître vers plusieurs esclaves et jamais d'esclave à 
esclave ou d'esclave à maître.

Slaves !
--------

Les esclaves maintenant (mouhahaha !).

Chacun des esclaves dispose de deux informations :

- son adresse (de 1 à 512) configurable
- le nombre fixe de canaux dont il a besoin

Le nombre de canaux requis dépend de l'équipement, pour un gradateur simple, il suffit souvent d'un canal.
Pour une lyre, on est à 6 ou 8 canaux, pour mon PAR Led, il en faut 6 :

- 3 pour les couleurs (RGB)
- 1 pour le mode macro
- 1 pour la vitesse du strob
- 1 pour les modes et effets

L'adresse est modifiable par l'opérateur, souvent via un dip switch situé sur le récepteur (arrière du projo ou base
pour une lyre).

Ce qu'il faut comprendre, c'est que chaque esclave reçoit la trame complète et qu'il ne *lit* que les **n** canaux dont
il a besoin, **adresse incluse**.

Le driver
=========
Rôle du driver
--------------

Dans les applications de communication, le *"driver"* est l'élément faisant le lien entre les systèmes communicants et
la liaison physique elle même.

Dans le cas particulier du DMX, il faut savoir que la liaison (physique) est symétrique.
C'est à dire que l'on envoie dans le lien la masse (qui sert de référence), et pour chaque fil de données on envoie
aussi l'inverse sur un second fil.
On note qu'avec un système comme celui là, le nombre minimum de brins est 3 (masse, D+, D-).

Pourquoi faire ça ?
~~~~~~~~~~~~~~~~~~~

.. image:: /static/images/dmx/chrono.png
    :align: right
    :width: 400px

Parce que cela constitue déjà un premier moyen de réduction du bruit sur la liaison.
L'explication à ça est visible sur le schéma ci-contre.

Lorsqu'une interférence apparait, elle apparait sur les deux fils de data et est supprimée par la soustraction.

Certes, le procédé n'est pas parfait, mais il élimine déjà une bonne partie des problèmes.

Dans un système donné, dépendant du temps, (un Arduino par exemple), les opérations codées sont éxécutées de manière
séquentielle.
Il est ainsi compliqué de passer strictement au même instant une pin à 0 et une autre à 1 (pour produire un signal
symétrique).

Ainsi, le driver (externe à l'Arduino, système communicant) permet de garantie la *symétrie* du signal.
C'est d'ailleurs son rôle premier, même s'il est souvent agrémenté d'autres fonctions (souvent liées à la protection du
système de commande).

Un driver bien fait
-------------------

Pour le DMX, le driver est souvent composé de quelques composants agencés autour d'un CI.

La référence revenant le plus souvent quand on parle de DMX à partir d'un arduino est certainement le **MAX485** de chez
*Maxim*.

C'est d'ailleurs la référence proposée pour le `Fritzing diagram of the simplest Arduino based DMX master possible`_.

Il font aussi état d'une autre référence : le 75176, normalement moins cher.

Bref, il faut du matériel et donc, c'est pas rigolo.

Un driver à l'arrache
---------------------

Tout est parti d'un de mes tweets :

    A votre avis, on peut recréer une trame DMX avec un alim ATX, un transistor, une resistance et un arduino ?

Ce à quoi `@jblb_72`_ s'est empressé de répondre *"2 résistances"*.

.. image:: /static/images/dmx/driver_min.png
    :width: 600px
    :align: center

On arrive à un schéma comme celui ci-dessus.

Il vient violement contredire le lien mis précédement : celui ci **est** le driver le plus simple et minimaliste qui soit.

Attention toutefois, le schéma que je propose ici est potentiellement **dangereux** : il ne procure aucune protection
contre les boucles de masse, et aucune isolation vis a vis de l'arduino lui même.

Bref, il marche super bien tant qu'on s'en sert pas dans des conditions hardcore.

Le DMX n'a (je viens de le vérifier) aucune indication de plus que celle de la RS-485 (sur laquelle il est basé)
concernant les voltages à utiliser.
La RS-485 demande un voltage compris entre -7V et +12V, un 0 est compris lorsque la différence entre DATA+ et DATA- est
inférieure à -200mV et un 1 lorsqu'elle est supérieure à 200mV.
En fixant nos bornes à 0V et 5V, on a effectivement :

- ``5V - 0V > 200mV`` => 1 reconnu
- ``0V - 5V < -200mV`` => 0 reconnu

Donc, contrairement à ce que dit `cette page`_ on peut parfaitement utiliser un truc à l'arrache utilisant les 0V et 5V
de l'arduino sans mapper vers [-2.5V ; 2.5V] comme le fait le shield DMX présenté.

Enfin, vous aurez noté que j'ai utilisé un transistor 2N2222 (NPN) et des résistances de 1kOhm.
Certains diront que 100Ohms auraient suffit à saturer le transistor et à provoquer ce qu'on voulait, c'est vrai, mais
j'ai pris les premières qui venaient, donc, c'était des 1kOhm. Et tant pis.

Enfin, pour ce qui est de la connexion, il faut s'arranger pour mettre les fils de droite (sur le schéma) en
correspondance avec les contacts de la fiche XLR.

Le DMX propose de travailler avec du 5 points, mais en fait, les contacts 4 et 5 servent en théorie pour un lien de
données secondaire, ici, on en a pas besoin, donc un XLR 3 points fera très bien l'affaire (une aubaine, mon PAR est équipé de fiches 3 points).

Les correspondances sont les suivantes (il y des petits numéros sur les fiches XLR : 1, 2 et 3) :

- fil du haut (D+) => 3
- fil du milieu (D-) => 2
- fil du bas (masse) => 1

Le programme
============

La lib DmxSimple
----------------

A ceux qui pensaient que j'allais ré-implémenter DMX 512, désolé de vous décevoir mais c'est pas spécialement mon truc
(même si je suis sûr que ça aurait été intéressant).

Une lib DMX existe pour l'arduino, elle s'appelle DmxSimple_ et fait partie du projet *Tinker.it*.

On va donc se contenter d'installer la lib et de la modifier un peu pour qu'elle nous convienne.

Au fait, la lib DmxSimple **utilise la pin 3 par défaut** on va donc brancher le driver sur cette pin.

On commence donc par récupérer et décompresser la lib et la décompresser : ::

    $ cd /tmp
    $ wget http://tinkerit.googlecode.com/files/DmxSimple_v3.zip
    $ unzip DmxSimple_v3.zip

Pour l'instant, la lib est dans ``/tmp/DmxSimple/``, on va maintenant éditer le fichier ``/tmp/DmxSimple/DmxSimple.cpp``
pour remplacer la ligne 11 :

.. code-block:: c

    #include "wiring.h"

par :

.. code-block:: c

    #include "Arduino.h"

En effet, la lib ``wiring.h`` a été remplacée par ``Arduino.h`` depuis Arduino 1.0.0.

Reste à "installer" la lib via un simple : ::

    $ sudo cp -r DmxSimple /usr/share/arduino/libraries/

Un script simple sur 3 couleurs
-------------------------------

Pour commencer, on va juste écrire un petit programme simple : on envoie un cycle rouge-vert-bleu en boucle.

.. code-block:: c

    // Inclusion de la lib DmxSimple
    #include <DmxSimple.h>

    // La fonction setup est obligatoire
    // On la définie mais on la laisse vide :
    // on en a pas besoin.
    void setup() {}

    // La classique loop
    void loop()
    {
        // On défini un tableau sur lequel on va boucler.
        // Une couleur = un sous-tableau de 6 octets contenant
        // chacun la valeur d'un des 6 canaux requis par le projecteur.
        // Les 3 derniers sont nul car inutiles ici.
        // Les 3 premiers sont respecivement Rouge, Vert et Bleu
        int colors[3][6] = {
            {0xFF, 0, 0, 0, 0, 0},
            {0, 0xFF, 0, 0, 0, 0},
            {0, 0, 0xFF, 0, 0, 0}
        };

        int i, j; // variables d'itération
        for (i = 0; i < 3; i++) {
            // pour chaque couleur...
            for (j = 0; j < 6; j++) {
                // on envoie tour a tour le canal correspondant
                // DmxSimple.write(canal, donnée);
                DmxSimple.write(j+1, colors[i][j]);
            }
            // on attend un peu avant de passer à la suite.
            delay(200);
        }
    }

Il n'y a rien de compliqué et si vous testez, vous verrez que ça marche.
C'est le programme qui est utilisé sur `cette vidéo`_.

Un changement plus soft
-----------------------

On peut aussi essayer d'imposer une forme de *gradient* en allant par exemple de ``#FF0000`` (rouge) à ``#FFFF00``
(jaune).

Pour cela, on peut utiliser un programme comme celui ci :

.. code-block:: c

    #include <DmxSimple.h>

    // valeur min pour le second byte
    #define MIN 0x00
    // valeur max pour le second byte
    #define MAX 0xFF
    // temps entre chaque modif de couleur
    #define DELAY 100

    void setup()
    {
        // cette fois, on initialise notre pojecteur en rouge
        int colors[6] = {0xFF, 0, 0, 0, 0, 0};
        int i;
        for (i = 0; i < 6; i++) {
            DmxSimple.write(i+1, colors[i]);
        }
    }

    void loop()
    {
        // On envoie ensuite juste le second byte
        int i = MIN;
        while (i < MAX) {
            // on fait monter i de 1 en 1 de MIN à MAX
            // et on écrit la donnée
            DmxSimple.write(2, i);
            i++;
            delay(DELAY);
        }
        while (i > MIN) {
            // et maintenant, dans l'autre sens
            DmxSimple.write(2, i);
            i--;
            delay(DELAY);
        }
    }

Toujours rien de violent hein ! On se contente de deux boucles pour créer une impression de va et vient.

Et maintenant
=============

On arrive presque à la fin de cet article et on sait désormais fabriquer à l'arrache un driver DMX et l'utiliser via
l'arduino.
C'est plutot une bonne chose.

Interface python ?
------------------

On pourrait envisager pour la suite de se servir de l'arduino comme un simple intermédiaire que l'on commanderait via la
liaison série depuis un programme python par exemple (une belle interface graphique ;)).

Android
-------

On peut aussi essayer de relier l'Arduino à un téléphone type Android (ou iOS, mais Android c'est mieux ;)</troll>).
L'idéal serait de le faire en Bluetooth ou Wifi (via un Ethernet Shield + PoE).

A tester...

Conclusion
==========

Finalement, il n'y avait pas de grosse difficulté même si on a un peu cheaté en trouvant une lib sur Internet.

La ré-implémentation de DMX 512 est un challenge qui pourrait être intéressant et je pense que je finirais par m'y mettre.

Maintenant, je vais jouer avec la loupiotte !

**EDIT :** Une `petite photo`_ (à l'arrache aussi) du driver bricolé sur un domino. On retrouve en haut (de gauche à droite) :

- masse vers arduino
- 5V vers arduino (résistance)
- Data vers arduino (pin 3)

En bas :

- masse
- D-
- D+

.. _@jblb_72: http://twitter.com/jblb_72
.. _DMX WithOut Wire: http://www.goddarddesign.com/wspread.html
.. _Art-Net: http://en.wikipedia.org/wiki/Art-Net
.. _Fritzing diagram of the simplest Arduino based DMX master possible: http://fritzing.org/projects/arduino-to-dmx-converter/
.. _cette page: http://arduino.cc/playground/DMX/DMXShield
.. _DmxSimple: http://code.google.com/p/tinkerit/wiki/DmxSimple
.. _cette vidéo: http://www.youtube.com/watch?v=Briwa3AT9fg
.. _petite photo: https://pbs.twimg.com/media/A22ZEgMCcAEgvFw.jpg
