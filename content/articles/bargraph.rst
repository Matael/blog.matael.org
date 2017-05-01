========
Bargraph
========

:date: 2015-01-04 11:20:58
:slug: bargraph
:authors: matael
:summary: 
:tags: arduino, imported

Dans la série "utilisons des LEDs et des 74HC595", voici le bargraph...

Dans le cadre du HAUM, un hackerspace monté au mans avec le concours de
l'université (surtout du département info), je me suis lancé dans des
tests autour des bargraphs.

---------------------
Qu'est ce que c'est ?
---------------------

Un bargraph, c'est une rangée de LEDs réagissant à un signal. Le signal
peut être de n'importe quelle sorte, mais le plus souvent, il s'git d'un
signal sonore. On trouve notamment des bargraphs sur les tables de
mixage, certains amplis, etc...

On utilise ce genre de choses pour donner une idée de **l'amplitude
moyenne d'un signal** (plus il y a de LEDs allumées, plus c'est fort).

Ici, on va essayer de faire fonctionner la barre de LEDs commandée *via*
l'arduino et deux 74HC595 (on aura donc 16 LEDs) d'abord en *standalone*
(pour tester) puis en réaction à la valeur d'un potentiomètre et d'une
LDR (photo résistance).

--------
Les LEDs
--------

Prenons le problème dans l'ordre. On cherche à créer un bargraph LED, il
nous faut donc des LEDs et de quoi les piloter.

Vu qu'on va utiliser l'arduino pour l'interface entre les données
(signal, valeur du potar/LDR) et l'affichage (les LEDs), on doit soit :

-  Se limiter dans le nombre de LEDs et oublier des circuits complexes
   (toutes les LEDs sont reliées à des pins différentes de l'arduino)
-  Utiliser un circuit d'interface pour lier l'arduino aux LEDs avec un
   minimum de pins.

J'ai choisi la seconde solution et, quitte à utiliser une interface, vu
les choses en grand avec 16 LEDs (soit 2 74HC595).

Ils seront donc chainés pour pouvoir piloter les 16 LEDs avec seulement
3 pins de l'arduino (tout en sachant que on aurait pu étendre ce nombre
à souhait en chainant d'autres circuits intégrés).

**Note :** J'ai horreur de devoir enficher 16 LEDs et 16 résistances
classiques à la main :

-  On peut se tromper de sens pour les LEDs
-  On a du mal à optimiser la place

J'ai donc choisi d'utiliser des barres de LEDs (ici 2 barres de 10
LEDs empaquetées corectement) et des réseaux de résistances (2 des 8
résistances + 4 resistances classiques pour l'appoint).

Les 4 LEDs en trop ne sont pas utilisées mais pourraient l'être.

Sur les schémas, Fritzing ne disposant pas de ces 2 composants, j'ai
utilisé des LEDs et des résistances classiques (et j'ai mis le bon
nombre ;) ).

Notons que même si ce ne sont que des LEDs, le montage consomme un peu.
Pour éviter tout problème, j'ai choisi de le faire tourner en utilisant
une alimentation ATX comme source d'énergie (en 5V).

~~~~~~~~~~~~~~~~~~
Du chainage des IC
~~~~~~~~~~~~~~~~~~

Les 74HC595 sont chainés comme je l'avais proposé
ici_ :

.. figure:: /static/images/74hc595/double.png
   :align: center
   :width: 500px

Les sorties ``Q0`` à ``Q7`` de chacun des deux IC sont raccordées aux
LEDs qui vont bien.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Schéma complet et explication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. figure:: /static/images/bargraph/bargraph.png
   :align: center
   :width: 500px

Vous pourrez trouver le fichier source pour fritzing_. 


***********
Explication
***********

On note 2 circuits :

-  En **violet** : le circuit vers l'entrée analogique. On a 2
   dispositifs : 1 potentiomètre (20kOhms) et une LDR (photorésistance).
   Pour éviter les montages à la *one-again* habituels (c'est pourtant
   ce que j'ai fait sur le proto physique), j'ai mis 3 bornes males
   reliables deux à deux au moyen d'un shunt pour le choix du circuit
   d'entrée.

-  En **bleu** : le circuit de *"données"*. En gros, les 2 pins DS des
   74HC595 et les lignes vers les leds.

La dernière chose à noter : j'ai mis 2 bornes (femelles cette fois) en
bout de breadboard. En effet, lorsque l'on commence à augmenter la
consommation potentielle, il vaut mieux passer par une alimentation
externe (le régulateur de l'arduino n'est pas toujours suffisant). Notez
aussi que l'arduino est alimenté sur les 2 lignes.

------------------------
Les différents pilotages
------------------------

Détaillons un peu les différents modes de pilotage dont nous avons parlé
tout à l'heure.

~~~~~~~~~~~~
Arduino seul
~~~~~~~~~~~~

Pour commencer, nous allons essayer de faire une simple chenillard LED
sur la rangée.

La partie la plus longue est celle définissant les différents *patterns*
à appliquer sur le bargraph. Ici, on aurait pu trouver plus simple que
de passer par un tableau, mais cela permet de voir le principe
d'utilisation d'un *charset* (ici, des *patterns*).

Voilà la liste des patterns utilisés :

.. code-block:: c

    const byte patterns[16][2] = {
        {B10000000, B00000000},
        {B01000000, B00000000},
        {B00100000, B00000000},
        {B00010000, B00000000},
        {B00001000, B00000000},
        {B00000100, B00000000},
        {B00000010, B00000000},
        {B00000001, B00000000},
        {B00000000, B10000000},
        {B00000000, B01000000},
        {B00000000, B00100000},
        {B00000000, B00010000},
        {B00000000, B00001000},
        {B00000000, B00000100},
        {B00000000, B00000010},
        {B00000000, B00000001}};

Comme on le voit, les patterns de 16bits chacun sont découpés en 2
valeurs de type ``byte`` stockées dans un tableau à 2 dimension.

Pour charger les 2 registres chaînés, il nous suffira d'envoyer d'abord
l'octet 1 puis l'octet 2 (case 0 puis case 1) de chaque ligne. Le
premier octet envoyé se loge dans le premier registre, puis on envoie le
second qui "pousse" le premier vers la pin ``Q7'`` et celui-ci vient
remplir le second registre.

La fonction ``loop()`` est particulièrement simple :

.. code-block:: c

    void loop()
    {
         int i = 0; // création de la variable d'itération
         for (i = 0; i < 16; i++) {
             digitalWrite(ST_CP, LOW); // blocage de la recopie
             shiftOut(DS, SH_CP, MSBFIRST, patterns[i][0]); // premier octet
             shiftOut(DS, SH_CP, MSBFIRST, patterns[i][1]); // deuxième octet
             digitalWrite(ST_CP, HIGH); // recopie
             delay(200);
         }
    }

Le code complet reste relativement trivial, je ne m'étendrais pas : les
commentaires suffisent.

.. code-block:: c

    #define DS 5    // pin de donnée des 74
    #define SH_CP 6 // pin d'horloge
    #define ST_CP 7 // pin de latch (recopie)

    void setup()
    {
        // décalaration des 3 pins en sortie
        pinMode(DS, OUTPUT);
        pinMode(ST_CP, OUTPUT);
        pinMode(SH_CP, OUTPUT);
    }

    const byte patterns[16][2] = {
        {B10000000, B00000000},
        {B01000000, B00000000},
        {B00100000, B00000000},
        {B00010000, B00000000},
        {B00001000, B00000000},
        {B00000100, B00000000},
        {B00000010, B00000000},
        {B00000001, B00000000},
        {B00000000, B10000000},
        {B00000000, B01000000},
        {B00000000, B00100000},
        {B00000000, B00010000},
        {B00000000, B00001000},
        {B00000000, B00000100},
        {B00000000, B00000010},
        {B00000000, B00000001}};

    void loop()
    {
         int i = 0; // création de la variable d'itération
         for (i = 0; i < 16; i++) {
             digitalWrite(ST_CP, LOW); // blocage de la recopie
             shiftOut(DS, SH_CP, MSBFIRST, patterns[i][0]); // premier octet
             shiftOut(DS, SH_CP, MSBFIRST, patterns[i][1]); // deuxième octet
             digitalWrite(ST_CP, HIGH); // recopie
             delay(200);
         }
    }

~~~~~~~~~~~~~~~~~~~~~~~~~~~
Réaction à un potentiomètre
~~~~~~~~~~~~~~~~~~~~~~~~~~~

L'adaptation du code est très simple ici. Il suffit d'une simple lecture
sur la bonne pin analogique (pour nous, la 0) et d'un remap de la valeur
depuis ``[0;1023]`` (le convertisseur analogique/numérique est sur 10
bits) vers ``[0;15]``.

En réalité, nous voulons que la valeur envoyée par le potentiomètre
influe sur la vitesse de passage d'une LED à la suivante. On va donc
changer la ligne contenant ``delay(200)`` par :

.. code-block:: c

    delay(map(analogRead(POTAR), 0, 1023, 25, 250));

Il faut aussi rajouter notre directive de pré-processeur définissant
``POTAR`` :

.. code-block:: c

    #define POTAR 0

~~~~~~~~~~~~~~~~~~
Réaction à une LDR
~~~~~~~~~~~~~~~~~~

La *LDR* (*Light Dependant Resistor* ou photorésistance) est un
composant dont la résistance varie en fonction de la luminosité. En
fait, plus l'environnement est lumineux, plus la valeur est grande (il
faudra d'ailleurs que j'essaye d'utiliser une LDR pour détecter des
couleurs).

Pour l'instant, notre bargraph n'en était pas vraiment un : il n'était
utilisé que comme afficheur piloté par une séquence prédéfinie et la
seule donnée récoltée (ici, la valeur d'un potentiomètre) ne servait que
pour choisir la fréquence de rafraichissement.

Maintenant, *level up* ! Cette fois, on utilise une LDR et on cherche à
créer un bargraph indicateur de luminosité.

-------------------
L'aspect général...
-------------------

... ne change pas !

C'est la même fonction ``setup()`` qu'avant et un ``#define`` à changé
de nom, mais à part ça, rien de nouveau pour le début du programme :

.. code-block:: c

    #define DS 5
    #define SH_CP 6
    #define ST_CP 7

    #define LDR 0

    void setup()
    {
        pinMode(DS, OUTPUT);
        pinMode(ST_CP, OUTPUT);
        pinMode(SH_CP, OUTPUT);
    }

Les patterns quant à eux ont très peu changé :

.. code-block:: c

    const byte patterns[16][2] = {
        {B01111111, B11111111},
        {B00111111, B11111111},
        {B00011111, B11111111},
        {B00001111, B11111111},
        {B00000111, B11111111},
        {B00000011, B11111111},
        {B00000001, B11111111},
        {B00000000, B11111111},
        {B00000000, B01111111},
        {B00000000, B00111111},
        {B00000000, B00011111},
        {B00000000, B00001111},
        {B00000000, B00000111},
        {B00000000, B00000011},
        {B00000000, B00000001},
        {B00000000, B00000000}};

~~~~~~~~~~~~~~~~~~~~~
Le coeur du programme
~~~~~~~~~~~~~~~~~~~~~

Il y a des fois ou la logique pose soucis.

********************
Hysteresis mon amour
********************

Si on teste une ``main`` comme celle ci :

.. code-block:: c

    void loop()
    {
         current = map(analogRead(LDR), 0, 1023, 0, 15);
         digitalWrite(ST_CP, LOW);
         shiftOut(DS, SH_CP, MSBFIRST, patterns[current][0]);
         shiftOut(DS, SH_CP, MSBFIRST, patterns[current][1]);
         digitalWrite(ST_CP, HIGH);
         delay(200);
    }

On va se rendre compte que.... ça marche pas très bien (voir carrément
mal).

Les coupure entre les intervalles représentés par les leds ne sont pas
nets.

Si on fait la division entière ``1023/16``, on trouve 63. Jusqu'a 63, on
utilise donc le pattern 0 et à 64, on utilise le pattern 1. Maintenant
imaginons que la valeur oscille entre 63 et 64... là, on a un truc
vraiment pas top.

L'hystérésis désigne l'écart entre 2 valeurs : ici l'écart entre
l'intervalle du pattern 0 et celui du patter 1 (etc...).

Grosso modo, plutôt que dire


    jusqu'a 63, t'es à 0, à partir de 64, t'es à 1

on va dire


    jusqu'a 60, t'es à 0 à partir de 70 t'es à 1 et entre les deux, tu
    restes comme tu étais avant

Pour implémenter ce comportement, j'ai choisi de passer par une fonction
:

.. code-block:: c

    int set_current_num(int value, int current)
    { 
        if (value < 64) { return 0; } 
        else if (value > 60 && value < 125) { return 1; }
        else if (value > 135 && value < 190) { return 2; }
        else if (value > 200 && value < 250) { return 3; }
        else if (value > 260 && value < 310) { return 4; }
        else if (value > 320 && value < 370) { return 5; }
        else if (value > 380 && value < 435) { return 6; }
        else if (value > 445 && value < 505) { return 7; }
        else if (value > 515 && value < 570) { return 8; }
        else if (value > 580 && value < 635) { return 9; }
        else if (value > 645 && value < 700) { return 10; }
        else if (value > 710 && value < 760) { return 11; }
        else if (value > 770 && value < 820) { return 12; }
        else if (value > 830 && value < 880) { return 13; }
        else if (value > 890 && value < 945) { return 14; }
        else if (value > 955) { return 15; }
        else { return current; }
    }

Elle prend comme paramètres, vous l'aurez compris, la valeur lue sur la
pin analogique et le numéro du pattern courant. Elle retourne un numéro
entre 0 et 15 inclus correspondant à un pattern.

De là, la ``main()`` devient simple :

.. code-block:: c

    void loop()
    {
         int current = 0; // on crée la variable une bonne fois pour toute

         for (;;) { // boucle de contrôle
             // on récupère le numéro de pattern
             current = set_current_num(analogRead(LDR), current);

             // et on l'envoie au bargraph
             digitalWrite(ST_CP, LOW);
             shiftOut(DS, SH_CP, MSBFIRST, patterns[current][0]);
             shiftOut(DS, SH_CP, MSBFIRST, patterns[current][1]);
             digitalWrite(ST_CP, HIGH);
             delay(200);
         }
    }

Aaaaaaaannnd... **it works** !

Voilà le code complet :

.. code-block:: c

    #define DS 5
    #define SH_CP 6
    #define ST_CP 7

    #define LDR 0

    void setup()
    {
        pinMode(DS, OUTPUT);
        pinMode(ST_CP, OUTPUT);
        pinMode(SH_CP, OUTPUT);
    }

    const byte patterns[16][2] = {
        {B01111111, B11111111},
        {B00111111, B11111111},
        {B00011111, B11111111},
        {B00001111, B11111111},
        {B00000111, B11111111},
        {B00000011, B11111111},
        {B00000001, B11111111},
        {B00000000, B11111111},
        {B00000000, B01111111},
        {B00000000, B00111111},
        {B00000000, B00011111},
        {B00000000, B00001111},
        {B00000000, B00000111},
        {B00000000, B00000011},
        {B00000000, B00000001},
        {B00000000, B00000000}};

    int set_current_num(int value, int current)
    { 
        if (value < 64) { return 0; } 
        else if (value > 60 && value < 125) { return 1; }
        else if (value > 135 && value < 190) { return 2; }
        else if (value > 200 && value < 250) { return 3; }
        else if (value > 260 && value < 310) { return 4; }
        else if (value > 320 && value < 370) { return 5; }
        else if (value > 380 && value < 435) { return 6; }
        else if (value > 445 && value < 505) { return 7; }
        else if (value > 515 && value < 570) { return 8; }
        else if (value > 580 && value < 635) { return 9; }
        else if (value > 645 && value < 700) { return 10; }
        else if (value > 710 && value < 760) { return 11; }
        else if (value > 770 && value < 820) { return 12; }
        else if (value > 830 && value < 880) { return 13; }
        else if (value > 890 && value < 945) { return 14; }
        else if (value > 955) { return 15; }
        else { return current; }
    }

    void loop()
    {
         int current = 0;

         for (;;) {
             current = set_current_num(analogRead(LDR), current);
             digitalWrite(ST_CP, LOW);
             shiftOut(DS, SH_CP, MSBFIRST, patterns[current][0]);
             shiftOut(DS, SH_CP, MSBFIRST, patterns[current][1]);
             digitalWrite(ST_CP, HIGH);
             delay(200);
         }
    }

----------
Conclusion
----------

On a donc désormais le moyen d'afficher un bargraph cohérent pour
n'importe quel signal.

Le but ultime de la conception d'un bargraph est de l'utiliser pour
quantifier un avec un signal sonore en provenance d'un lecteur mp3 par
exemple. Mais ça, ce sera pour une autre fois.

.. _ici:  /writing/arduino-et-registres
.. _fritzing: /static/images/bargraph/bargraph.fzz
