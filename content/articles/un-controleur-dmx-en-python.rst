===========================
Un contrôleur DMX en python
===========================

:date: 2015-01-04 11:28:39
:category: imported
:slug: un-controleur-dmx-en-python
:authors: matael
:summary: Parce que pouvoir tout contrôler depuis un pc, c'est cool
:tags: python, arduino, dmx

Cet article est une suite de l'article : `Arduino et DMX`_, il peut être bon de commencer par le début.

Résumé des épisodes précédents
==============================

Ayant acquis un projecteur LED avec une interface DMX 512, je me suis demandé si l'Arduino pouvait le contrôler.
Quelques tweets, un montage et un peu de code plus tard, ça fonctionnait.

Le problème suivant était de contrôler la bête depuis une application.

Choix techniques et déroulement
===============================

Choix Techniques
----------------

Pour la création de l'application elle même, je me rabat sur python et la *toolbox* graphique wxPython_.

    **Note :**

    Je ne vais pas détailler la création d'une appli wxPython (j'ai pas les connaissances pour ça, et ce n'est pas le
    but). Je montrerais les quelques bouts de code utiles et fournirais le fichier complet à télécharger.


Déroulement
-----------

L'article se présente comme suit :

#. Ré-écriture du code pour l'Arduino
#. Écriture de l'appli python
#. Lancement des deux et *"oh, c'est beau !"*

Arduino
=======

Au niveau du code Arduino, il va falloir tout ré-écrire.

On définira les 3 canaux associés aux 3 couleurs (R, G, B) en ``#define``.

La fonction ``setup()`` passe les 3 canaux à 0 et initialise la connexion série tandis que la fonction ``loop()`` remet
à jour les 3 couleurs si 3 octets au moins sont présents dans le *buffer* de la liaison :

.. sourcecode:: c

    #include <DmxSimple.h>
    #define CHAN_RED 1
    #define CHAN_GREEN CHAN_RED+1
    #define CHAN_BLUE CHAN_RED+2

    void setup()
    {
        int i;

        // On commence par passer tous les canaux à 0
        for (i=1; i<3; i++) {
            DmxSimple.write(i, 0x00);
        }

        // On initialise la connexion série
        Serial.begin(9600);
    }

    void loop()
    {
        if (Serial.available() >= 3) {
            DmxSimple.write(CHAN_RED, Serial.read());
            DmxSimple.write(CHAN_GREEN, Serial.read());
            DmxSimple.write(CHAN_BLUE, Serial.read());
        }
    }

Alors, oui, les puristes diront que l'on pourrait économiser des lignes de code en utilisant 3 boucles seulement, il se
trouve que ça fonctionnement nettement moins bien.
Essayez si vous voulez ;)

Python !!
=========

Le code python est celui d'une appli wxPython_ classique.

On crée d'abord la classe ``DMXController`` qui sera notre base et on s'arrange pour coller à nos *"specs"*...

Tiens, d'ailleurs, qu'est ce qu'on veut qu'elle fasse cette appli ?

- il faudrait pouvoir contrôler chaque canal séparément (genre avec des sliders)
- si on pouvait faire des flashes de couleur avec un bouton (comme sur les vraies consoles DMX) ce serait cool
- deux/trois macros aideraient pas mal :

  - BlackOut (tout éteint)
  - SpotLight (tout allumé)
  - Rouge
  - Vert
  - Bleu

- rechercher les ports série pouvant pointer vers un Arduino
- permettre de sélectionner le port série voulu

Le fichier final est `disponible ici`_, mais nous allons en détailler quelques points

Attention à la version
----------------------

Attention, il vous faudra un **python 2.7** pour exécuter le code. En effet, celui ci utilise les dict comprehension qui
ne sont pas apparus avant...

Sliders
-------

Les lignes 37 à 67 du fichier instancient les sliders et les boutons pour les flashes.
D'abord un *sizer* horizontal pour y mettre les sliders (l.38) puis les sliders eux-même et le ``Bind()`` qui va bien
(l.40 à l.46).

On boucle ensuite sur une liste de *tuples* contenant :

- une référence vers le slider
- le nom à donner au bouton associé
- une référence vers chacune des deux fonctions de *callback* pour les boutons (pressé et relâché)

La boucle :

#. crée un *sizer* vertical pour le couple slider/bouton
#. ajoute le slider au *sizer*
#. instancie le fameux bouton, l'ajoute à une liste puis le lie à ses deux *callback*
#. ajoute le bouton au *sizer* vertical
#. ajoute le *sizer* vertical à celui horizontal créé plus haut

Logger
------

La ligne 70 instancie une zone de texte en *read-only* pour pouvoir afficher nos messages à l'utilisateur
(particulièrement utile pendant le *debug*)...

Menu Ports
----------

On crée ensuite un menu pour les ports série.

On ajoute seulement l'entrée permettant de lancer la recherche de ports série, le menu lui même sera augmenté par la
fonction ``DMXController.FindSerialPorts()`` un peu plus tard.

Menu Macros
-----------

Les lignes 78 à 100 créent le menu pour les macros.
Chaque entrée est reliée à un *event handler* défini un peu plus bas.

Main Menu
---------

On crée un menu principal qui ne contient que l'entrée pour quitter l'application (l.104 à l.107).

Les lignes 109 à 124 ajoutent chacun des éléments dans les bons *sizers* et créent les barres (menu et *statusbar*)
nécessaire au bon fonctionnement du tout.

Enfin on lance une détection de ports en ligne 127 avant d'afficher la fenêtre en ligne 130.

Méthodes
--------

Les méthodes sont plutot bien commentées.

Les plus intéressantes sont ``FindSerialPorts``, ``SelectPort`` et ``send_values``.

J'aurais pu être plus propre que d'utiliser des fonctions de redirection pour les flashes et sliders, mais j'avoue que
sur le moment, j'ai pas pensé à faire autrement.

En action !
===========

C'est quand même le plus rigolo ;)

Arduino
-------

Pour l'arduino, compilez et uploadez ça comme n'importe quel script (pour l'installation de la lib DMX, regardez du côté
de l'`article précédent`_).

Python
------

Il vous faudra installer au moins **pyserial** et **wxpython**, par exemple, pour une ubuntu :::

    $ sudo apt-get install python-serial wxpython

devrait suffire, pour Arch :::

    $ sudo pacman -S wxpython
    $ sudo pip2 install pyserial

Sur Arch, ça installera aussi Python 2.7 si vous ne l'avez pas déjà.

.. image:: /static/images/dmx/controller.png
    :width: 300px
    :align: right

Finalement, on peut lancer l'application python via :::

    $ chmod u+x controller.py
    $ ./controller.py

Et vous aurez le rendu ci-contre.

Photos
------

Dans la foulée, j'ai aussi fait quelques photos que vous trouverez `sur Flickr`_.

Conclusion
==========

Ce n'est pas du grand art, mais ce petit utilitaire a au moins l'avantage d'être simple à utiliser et pas trop complexe
à modifier.

Cela nous permet en outre de jouer plus facilement avec le projecteur.

Next step : une mini-app Android (probablement via SL4A).

**PS : Un dépot Github existe :** `Matael/PyDMXController`_

.. _article précédent:
.. _Arduino et DMX: http://blog.matael.org/writing/arduino-et-dmx/
.. _wxPython: http://wxpython.org/
.. _disponible ici: /static/images/dmx/controller.py
.. _sur Flickr: http://www.flickr.com/photos/matael/sets/72157631703520608/with/8060145746/
.. _Matael/PyDMXController: https://github.com/Matael/PyDMXController
