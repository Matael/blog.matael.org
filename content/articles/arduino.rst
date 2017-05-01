=======
Arduino
=======

:date: 2015-01-04 11:20:57
:slug: arduino
:authors: matael
:summary: 
:tags: arduino, imported

Je vais vous parler de l'**arduino**, de ses possibilités, et par la
même occasion de programmes qui existent et qui peuvent être utiles pour
de l'électronique.

---------
Keskecé ?
---------

L'**arduino** est une petite **carte à microcontrôleur** programmable et
OpenSource fabriquée par la marque éponyme Arduino_.
Voilà quelques photos :

|Vue de biais| |Vue de dessus| |Vue de dessous| |Rabat intérieur du
paquet| |Manuel et stickers|

Cette carte, l'**Arduino Uno**, à l'*instar* de sa grande soeur
l'**Arduino Duemilanove**, mesure environ **52x65mm** (format
*"standard"* chez arduino). Cette carte, peut donc être programmée à
souhait au moyen d'un cable USB. Côté hardware, l'**Arduino Uno** est
équipée d'un microcontrôleur **AVR** de chez Atmel (l'**atmega328p**)
plutôt qu'un microcontrôleur PIC de microchip. Elle admet aussi une
alimentation autre grâce au **connecteur jack** dont elle est équipée ce
qui permet d'eviter les limitations de l'USB (besoin d'un PC pour n'en
citer qu'une). On remarque facilement sur la vue de dessus que l'arduino
est équipé de **4 rangées de pins** reliées comme il faut au
microcontroleur :

-  En haut à gauche : les deux plus à gauche sont **AREF** et **GND** et
   les suivantes les pins **numériques 8 à 13**
-  En haut à droite : les pins **numériques de 0 à 7** (sachant que les
   pins **0 et 1 sont aussi RX et TX et que 2 et 3 sont Inter0 et
   Inter1**)
-  En bas à gauche : les pins relatives à **l'alimentation et au
   fonctionnement interne (RESET, 3.3V, 5V, GNDx2 et Vin)**
-  En bas à droite : les pins **analogique de A0 à A5**

Enfin, il faut savoir que la **pin numérique 13 est reliée à une led**
intégrée à la carte et que la **pin RESET est reliée à GND** via un
poussoir présent sur la carte.

Un autre atout majeur de l'**arduino** est son prix : cette carte ne
coute que **25 EUR** !! Ce qui en fait un outil génial pour apprendre un
peu et bidouiller beaucoup !

----------------------
Programmer la bestiole
----------------------

Le plus drole quand on a un nouveau joujou, c'est de l'utiliser... On va
donc voir un programme tout simple pour l'**arduino** : **faire
clignoter la led associée à la pin 13**.

~~~~~~~~~~~~
Le programme
~~~~~~~~~~~~

L'**arduino** se programme avec un langage très proche du C. Vous avez
deux moyens de coder pour l'arduino : soit avec le `programme fourni par
arduino`_ soit avec votre éditeur
préféré (**VIIIM !!!**) en faisant toutefois attention au nom du dossier
et du fichier de code (en .pde), qui doivent être les mêmes :

.. code-block:: bash

    blink
    +-- blink.pde

Rien de bien compliqué donc !

Voici maintenant à quoi ressemble le programme lui même :

.. code-block:: c 

    // On défini la pin de la led
    int ledPin = 13;

    // Cette fonction n'est exécuté qu'au démarrage de la carte ou 
    // lors d'un RESET
    void setup()
    {
        // On précise que la pin est utilisée en sortie
        pinMode(ledPin, OUTPUT);
    }

    // Cette fonction sera exécuté en boucle
    void loop()
    {
        // On passe la pin en niveau haut
        digitalWrite(ledPin, HIGH);
        // On attend un peu
        delay(300);
        // On la met au niveau bas
        digitalWrite(ledPin, LOW);
        // On attend encore
        delay(300);
        // et c'est reparti pour un tour
    }

Ce programme, largement commenté reste trivial, aussi, je ne vais pas
m'y attarder... Il est juste bon de savoir que le code minimal d'un
programme pour arduino se résume à :

.. code-block:: c

    void setup()
    {
    }

    void loop()
    {
    }

Passé ceci, vous faites ce que vous voulez. A ce propos, vous pourrez
trouver la `doc utile`_ ici sur le site
d'**arduino**.

~~~~~~~~
L'upload
~~~~~~~~

Reste maintenant à compiler ce programme et à l'uploader sur la carte.
Pour la compilation, c'est l'affaire d'``avr-gcc`` et pour l'upload
celui d'``avrdude``. Cette partie m'a posé pas mal de problème au début
: je hais l'IDE d'arduino aussi, je voulais **uploader via la ligne de
commande** pour n'avoir qu'a envoyer la commande depuis Vim. Mais là,
problème : l'upload via la ligne de commande plantait à tous les coups.
J'ai essayé plusieurs MakeFiles et Scons, mais pas moyen et puis je me
suis décidé à suivre `ces
instructions`_
et là : **No Problem** ! Le programme s'est uploadé sans soucis et tout
à fonctionné parfaitement ! Voici donc le
MakeFile_ >`_ que j'ai utilisé pour compiler et
uploader la chose. Pour ceux qui les auraient oubliées, voici les
commandes qui vont bien :

.. code-block:: bash

    cd /le/dossier/du/projet/
    make
    make upload

Et zou ! Tout fonctionne !

----------------------
Deux, trois trucs cool
----------------------

~~~~~~~~~~~~~~~~~
Planche à Pain !!
~~~~~~~~~~~~~~~~~

Le premier s'appelle une **plaque de prototypage** (*breadboard* en
anglais, d'où le titre ;) ). Quand vous devez souvent changer de
montage, la soudure devient vite déconseillée :

*  Longue
*  La chaleur abime les composants

Aussi, vous pouvez vous procurer ceci :

|Plaque de proto|
Celle ci est cablée et c'est une 840 trous à 2 BUS. Largement suffisant
pour des circuits de base. Ce genre de plaque coûte une dizaine d'euros

~~~~~~~~
Software
~~~~~~~~

Deux softwares plutôt sympa pour l'electronique :
KTechLab_ et
`Fritzing Alpha`_.

Le premier fait pleins de trucs allants de la programmation Flowcode au
Schéma PCB (*Printed Circuit Board*) en passant par de la schématisation
pure. L'autre fait juste les schémas breadboard, et les PCB, mais les
fait bien !

~~~~~~~~
Hardware
~~~~~~~~

Pour ceux qui serait extrèmement attachés à Microchip ou qui
préfèreraient le *Basic* au *C*, il exsite une carte équipée d'un **PIC
18F25K20** de Microchip. Cette board est développée par `Crownhill
Associates Limited`_ et répond au nom
d'`Amicus 18`_. Voilà donc pour ce qui
est des microcontrôleurs alternatifs...

Reste quand même à vous dire que des clones d'**arduino** ont fait leur
apparition : Freeduino_,
Netduino_,
Boarduino_,...

Cette dernière est d'ailleurs fabricable soi-même sans trop de
difficultées.

.. |Vue de biais| image:: /static/images/arduino/PIC_0001-1.JPG
    :width: 600px
.. |Vue de dessus| image:: /static/images/arduino/PIC_0038.JPG
    :width: 600px
.. |Vue de dessous| image:: /static/images/arduino/PIC_0040.JPG
    :width: 600px
.. |Rabat intérieur du paquet| image:: /static/images/arduino/PIC_0046.JPG
    :width: 600px
.. |Manuel et stickers| image:: /static/images/arduino/PIC_0043.JPG
    :width: 600px
.. |Plaque de proto| image:: /static/images/arduino/SL271969.JPG
    :width: 600px
.. _Arduino: http://www.arduino.cc
.. _programme fourni par arduino: _http://arduino.cc/en/Main/Software
.. _doc utile: http://www.arduino.cc/en/Reference/HomePage
.. _ces instructions: https://wiki.archlinux.org/index.php/Arduino#Using_a_Makefile_instead_of_the_IDE
.. _Makefile: /static/files/arduino/Makefile
.. _KTechLab: http://sourceforge.net/projects/ktechlab/
.. _Fritzing Alpha: http://fritzing.org/
.. _Crownhill Associates Limited: http://www.crownhill.co.uk
.. _Amicus 18: http://www.myamicus.co.uk/
.. _Freeduino: http://www.freeduino.org
.. _Netduino: http://netduino.com/
.. _Boarduino: http://www.adafruit.com/category/19
