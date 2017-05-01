====================
Arduino et Registres
====================

:date: 2015-01-04 11:20:57
:slug: arduino-et-registres
:authors: matael
:summary: 
:tags: arduino, imported

C'est beau la programmation et l'utilisation de pins une par une. Il y a
toutefois un problème à cette conception : lorsqu'avec un arduino on
souhaite piloter un **afficheur ou une série de LEDs** (à plus forte
raison plusieurs afficheurs ou série de LEDs), on se retrouve vite à
cours de pins. C'est là qu'apparaisent : les **registres à décalage** !!

**Note : tous les fichiers utilisés y compris les images ou les sources
sont téléchargeables en bas de page**

------------------
Registres à quoi ?
------------------

Un registre à décalage est un système logique permettant la
restranscription/mémorisation des données depuis une connexion
série/parallèle et leur restitution vers une interface série/parallèle.
D'après wikipedia :

    Un registre à décalage est un registre, c'est-à-dire un ensemble de
    bascules synchrones, dont les bascules sont reliées une à une, à
    l'exception de deux bascules qui ne sont pas forcément reliées. A
    chaque cycle d'horloge, le nombre représenté par ces bascules est
    mis à jour.

On peut utiliser ce type de registre pour une simple conversion
série/parallèle en commandant l'output à grands coups de porte ``AND``
entre les sorties et une horloge de fréquence *n* fois inférieure à
celle de l'horloge de décalage de bit (avec *n* le nombre de bit
stockés).

Dans cette article, nous parlerons du **74HC595**. Un registre à
décalage standard avec mémorisation et sortie à 3 états.

----------
Le 74HC595
----------

... se présente sous la forme d'un petit *IC* (*integrated circuit* ou
*circuit intégré (CI)* en français) **enpaqueté DIP16**. Il a donc 8
broches de chaque côté et la numérotation de celles ci se fait d'une
manière on ne peut plus classique. Voici les fonctions des pins :

-  1 à 7 : ``Q1`` à ``Q7``, sorties parallèles 1 à 7
-  8 : ``GND``, masse (*0V*)
-  9 : ``Q7'``, sortie série
-  10 : ``/MR``, remise à zéro (*master reset*) **active au niveau bas**
-  11 : ``SH_CP``, horloge de décalage (*shift clock*)
-  12 : ``ST_CP``, stockage (*latch*)
-  13 : ``/OE``, sortie active (*Output Enabled*) **active au niveau
   bas**
-  14 : ``DS``, entrée série
-  15 : ``Q0``, sortie parallèle 0
-  16 : ``Vcc``, alimentation (*+5V*)

~~~~~~~~~~~~~~~~~
Schéma équivalent
~~~~~~~~~~~~~~~~~

|image0|

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Principe de fonctionnement du 74HC595
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Malgré une datasheet obscure (mais que vous pourrez trouver dans les
liens en bas de la page), le fonctionnement de cet IC est simplissime.
L'alimentation du 74HC595 se fait sur la **pin 16** sous une tension
allant de **-0.5 à +7V** (toujours d'après la datasheet). Pour ce qui
est des Fonctions principales de la bête (à savoir registre à décalage,
enregsitrement du registre et sortie à 3 états), on utilisera les **8
pins** de sortie parallèles (**1 à 7 + 15**), plus les 3 à 5 pins de
contrôle.

Voici en gros la séquence effectué pour l'envoie d'une donnée sur 8bits
en sortie du 74HC595 : on passe d'abord ``ST_CP`` à 0, puis on présente
un par un les 8 bits de la donnée sur ``DS`` en envoyant en même temps
un **1 logique** sur ``SH_CP`` à chaque fois, on repasse ensuite
``ST_CP`` à 1 pour recopier la nouvelle valeur dans le second registre.

La **pin 10** (``/MR``) permet de remettre tout le premier registre à
zéro et **est active au niveau bas**, il convient donc (pour éviter une
remise à zéro permanente du registre) de **placer cette pin au niveau
haut** (on note que la plupart du temps on reliera cette pin à ``+Vcc``.

La **pin 13** (``/OE``) active ou non la sortie (elle est elle aussi
**active au niveau bas**). On placera cette fois cette pin **sur la
masse** ou bien sur une sortie du microcontrôleur pour pouvoir en
contrôler l'état.

~~~~~~~~~~~~~~~~~~~~~~~~~~~
A propos du troisième étage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Comme vous avez pu le voir sur le schéma équivalent du 74HC595, il est
composé de **3 étages**. Les deux premiers sont composés de **bascules
D** (disposée en regsitre à décalage pour le premier et en mémoire
parallèe pour le second), ces deux premiers étages sont donc triviaux.

Le 3ème étage quant à lui est composé de **sorties à 3 états**
commandées par la pin ``/OE``. Le fonctionnement des sorties à 3 états
est simple. Pour deux des états, il s'agit des classiques **0 et 1
logiques**. Dans le cas ou ``/OE`` est au niveau bas, cette sortie est
un simple fil.

Par contre, dans le cas ou ``/OE`` est au niveau logique haut (quand la
sortie est désactivée), cet étage atteint un état de **haute impédance**
qui n'est ni zéro, ni un (ni rien d'exploitable à ma connaissance) mais
qui à le bénéfice d'isoler efficacement le **74HC595** du reste du
circuit.

~~~~~~~~~~~~~~~~~~~
Utilité de la pin 9
~~~~~~~~~~~~~~~~~~~

La pin 9 du **74HC595** correspond à sa sortie série. On est en droit de
se demander *mais, à quoi ça sert de rentrer en série pour... ressortir
en série ?* La question vaut au moins un peu le détour : en utilisant la
sortie série, on peut **chaîner les 74HC595** et avoir ainsi des
registres à décalage sur 16, 24, 32 etc... bits. il suffit alors de
bidouiller un truc comme ça :

|image1|
On peut alors utiliser les **Q0 à Q7** du *CI* du haut pour les 8 bits
de poids faible (si on balance les poids fort en premier, voir après) et
ceux du second pour les 8 de poids fort. On aurait :

-  en vert : ``DS``
-  en bleu : ``ST_CP``
-  en rouge : ``SH_CP``

**Attention, les entrées sont à droite et les sorties à gauche**

-------------------
Arduinisons tout ça
-------------------

... ou comment utiliser les registres avec l'arduino

~~~~~~~~
ShiftOut
~~~~~~~~

Au cas où vous l'aurez pas remarqué, piloter un **74HC595** en dur,
c'est un peu la mort. On peut envisager la chose comme ça:

.. code-block:: c

    int i;
    int byte data;
    digitalWrite(ST_CP, LOW);
    for(i = 0; i < 8; i++) // pour chaque bit de la donnée
    {
        digitalWrite(DS, bitRead(data,i)); // on présente le bit
        digitalWrite(SH_CP, HIGH); // On fait pulser la pin SH_CP
        digitalWrite(SH_CP, LOW);  // pour écrire le bit
    }
    digitalWrite(ST_CP, HIGH);

Attention, je n'ai pas testé ce code, mais normalement, il devrait
permettre le transfert d'une donnée 8bit vers le **74HC595**.

C'est un peu lourd non ? Pour palier au problème : **la fonction
``shiftOut()``** ! Voilà le prototype de la bestiole (elle est définie
dans ``/path/to/arduino/hardware/arduino/cores/wiring_shift.c``):

.. code-block:: c

    void shiftOut(uint8_t dataPin, uint8_t clockPin, uint8_t bitOrder, uint8_t val);

On a donc besoin de 3 pins : ``dataPin`` et ``clockPin`` utilisées par
``shiftOut`` et ``latchPin`` pour bloquer ou non la recopie sur le
second registre.


**A propos de bitOrder** :
Cet argument peut être égal à ``LSBFIRST`` ou ``MSBFIRST``. Dans le
premier cas, ``shiftOut`` enverra les bit de poids faible en premier
alors que dans le second, elle commencera par ceux de poids fort.


On pourrait réécrire l'exemple précédent avec ``shiftOut`` :

.. code-block:: c

    int i;
    int byte data;
    digitalWrite(ST_CP, LOW);
    shiftOut(DS, SH_CP, LSBFIRST, data);
    digitalWrite(ST_CP, HIGH);

~~~~~~~~~~~~~~~~~~~~
Application pratique
~~~~~~~~~~~~~~~~~~~~

Bon, c'est pas tout, mais on est là pour bidouiller quand même !
Voici un petit sketch arduino pour l'utilisation de ``shiftOut`` dans le
cadre d'un petit chennillard.

**Bonus :** (ou pas) la vitesse de parcours est réglable au moyen de la
fonction ``analogRead`` et surtout d'un potentiomètre (ici du 10kOhms).

*************************
Le schéma | La breadboard
*************************

|image2| |image3|

**Attention : le 74HC595 est retourné !!**


*********
Le code !
*********

.. code-block:: c

    // Comme d'habitude, on défini les pins avec des defines
    #define ANA 0    // potar
    #define SHIFT 5
    #define LATCH 6
    #define DATA 7

    // Table des trucs à afficher (1 = led allumée)
    const byte chars[8] = {
        B00000001,
        B00000010,
        B00000100,
        B00001000,
        B00010000,
        B00100000,
        B01000000,
        B10000000};

    int time_delay = 500; // Delay de base

    void setup()
    {
        // On déclare les pins vers le 74HC595 en sortie
        pinMode(SHIFT, OUTPUT);
        pinMode(LATCH, OUTPUT);
        pinMode(DATA, OUTPUT);
    }

    void loop()
    {
        int i;
        // On boucle sur le tableau char
        for (i = 0; i < 8; i++) {
            digitalWrite(LATCH, LOW);  // bloque la recopie
            // On balance la donnée dans le premier étage
            shiftOut(DATA, SHIFT, MSBFIRST, chars[i]);
            digitalWrite(LATCH, HIGH);// recopie
            // On contrôle le potar pour déterminer le delay
            time_delay = map(analogRead(ANA), 0, 1023, 10, 500);
            delay(time_delay);
        }
    }

Vous pouvez aussi `le télécharger`_.

Bien entendu, vous pouvez utiliser ces ICs por commander des afficheurs
7 segments ! (ils ont 8 pins de contrôle : 7 segment + point décimal).

Dans un prochain article, on verra comment multiplexer les afficheurs et
74HC595 !

-----
Liens
-----

-  la `datasheet du 74HC595`_
-  le zip_ de tous les fichiers liés au 74HC595 (+ cet article)

.. |image0| image:: /static/images/74hc595/schema.svg
    :width: 600px
.. |image1| image:: /static/images/74hc595/double.png
    :width: 600px
.. |image2| image:: /static/images/74hc595/demo_schem.png
    :width: 600px
.. |image3| image:: /static/images/74hc595/demo_bb.svg
    :width: 600px
.. _le télécharger: /static/files/74HC595/74HC595.pde
.. _datasheet du 74HC595: /static/files/74HC595/74HC595.pdf
.. _zip: /static/files/74HC595/74HC595.zip
