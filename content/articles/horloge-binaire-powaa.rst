=====================
Horloge Binaire Powaa
=====================

:date: 2015-01-04 11:20:57
:slug: horloge-binaire-powaa
:authors: matael
:summary: 
:tags: arduino, imported

Entre deux plages de boulot, je me suis décidé à bidouiller une
**horloge binaire** avec l'arduino et une poignée de LEDS. Mieux encore,
elle est équipée d'une **alarme** !

-----
Avant
-----

C'est donc en triturant un peu l'arduino que je me suis dit que ce
serait cool de faire une **horloge** avec !

Voilà à quoi ça ressemble une fois fini :

|En fonctionnement|

~~~~~~~~~~~~~~~~~~~~~~~~~
Comment calculer le temps
~~~~~~~~~~~~~~~~~~~~~~~~~

Ça été (logiquement) le premier dilemme à résoudre sans quoi, aucune
**horloge** n'aurait pu fonctionner. Il faut savoir (si vous avez lu la
doc, ça ne devrait pas poser de problème) qu'il existe la fonction
``millis()`` qui renvoie le **nombre de millis secondes écoulées depuis
la mise sous tension** de l'arduino. Plutot sympa non ?

~~~~~~~~~~~~~~~~~~~~~~~~
Comment afficher l'heure
~~~~~~~~~~~~~~~~~~~~~~~~

Là, j'ai un peu spoilé.... Avec des LEDs bien sûr, présenté en binaire.
Et pour le code : à grands coups de division et de modulo ! On affichera
les heures sur 5 bits et les minutes sur 6.

Le principe est simple :

.. code-block:: c

    // variables pour les numéros de pins
    // vu que c'est pour l'exemple, 
        // j'initialise les variables sans valeur...
    // heures
    int h1;
    int h2;
    int h4;
    int h8;
    int h16;
    // minutes
    int m1;
    int m2;
    int m4;
    int m8;
    int m16;
    int m32;

    int heures = NOMBRE_HEURES;
    int heures_restantes;
    // affichage des heures
    if ((heures/16) >=1) { digitalWrite(h16, HIGH); 
        heures_restantes = heures%16;} else { digitalWrite(h16, LOW);}
    if ((heures_restantes/8) >=1) { digitalWrite(h8, HIGH); 
        heures_restantes = heures%8;} else { digitalWrite(h8, LOW);}
    if ((heures_restantes/4) >=1) { digitalWrite(h4, HIGH); 
        heures_restantes = heures%4;} else { digitalWrite(h4, LOW);}
    if ((heures_restantes/2) >=1) { digitalWrite(h2, HIGH); 
        heures_restantes = heures%2;} else { digitalWrite(h2, LOW);}
    if ((heures_restantes/1) >=1) { digitalWrite(h1, HIGH); 
        heures_restantes = heures%1;} else { digitalWrite(h1, LOW);}

    // même principe pour les minutes...

Voilà donc pour l'affichage.

Mais ! Une alarme, ce serait cool !
-----------------------------------

Allons y pour une alarme ! On utilisera une LED de plus, raccordée à une
pin libre, que l'on oubliera (évidement) pas de déclarer en
**output**...

Pour ce qui est de l'alarme, voilà mon bout de code :

.. code-block:: c

    // Règlage de l'Alarme
    #define AL_H 15   // heures
    #define AL_M 30   // minutes

    // [...]

    //    Alarme
    int alarmeSet[] = {AL_H, AL_M};

    // [...]

    void alarm()
    {
        // --- Vérifie si c'est l'heure et déclenche l'alarme
        if ((heures == alarmeSet[0])
            && (minutes == alarmeSet[1])
            && secondes == 0) {
            digitalWrite(alarme, HIGH);
        }
    }

Ensuite, il ne nous reste qu'a appeler la fonction ``alarm()`` à chaque
incrémentation des secondes, minutes et/ou heures. ***Note*** : il n'y
avait aucune raison *valable* d'utiliser un tableau pour les règlages de
l'alarme (``alarmeSet``), mais j'avais envie...

Super mais la LED elle reste allumée là !
-----------------------------------------

Pour ça, y'a un moyen tout simple : le bouton ! J'ai choisi de gérer le
bouton d'arrêt d'alarme avec une interruption, mais j'aurais pu utiliser
un simple ``digitalRead()`` dans la ``loop()``. Je détaillerais dans un
autre article l'usage des interruptions, pour l'instant contentez vous
de savoir que la fonction d'arrêt ressemble à ça :

.. code-block:: c

    void stop_alarme()
    {
        // --- Arrête l'alarme
        digitalWrite(alarme, LOW);
    }

Trivial hein ?!

Et qu'elle sera appelée à chaque appui sur le bouton grâce à ces deux
lignes dans la ``setup()`` :

.. code-block:: c

        // bouton en input
        pinMode(on_off, INPUT);
        // interruption
        attachInterrupt(0, stop_alarme, RISING);

Et voilà pour l'alarme !

Brochage
--------

Petit schéma de brochage sur une breadboard avec le logiciel Fritzing
Alpha :

|schéma de brochage|
Les LEDs utilisées sont des 3mm, les résistances sont en 220Ohms pour les
LEDs et en 470Ohms. Le bouton est un poussoir des plus classiques...

Attention toutefois : sur ce schéma, la plaque est mise à l'envers et se
lit donc de droite à gauche... Au niveau des broches :

-  pin 0 : Alarme
-  pin 1 : Trotteuse
-  pin 2 : Bouton poussoir
-  pin 3 à 7 : Leds des heures
-  pin 8 à 13 : Leds des minutes

Un peu de lecture
-----------------

Pour comprendre comment lire tout ça, voilà une petite image :

|Explication pour la lecture|
Le code
=======

Comme promis, voici le code complet :

.. code-block:: c

    ////////////////////////////
    // Horloge Binaire        //
    // Le 26 juillet 2011     //
    // pour blog.matael.org   //
    ////////////////////////////

    // L'heure est à règler ici
    #define HEURES 13
    #define MINUTES 41
    #define SECONDES 0

    // Règlage de l'Alarme
    #define AL_H 15   // heures
    #define AL_M 30   // minutes


    // Variables
    //    HMS
    int heures = HEURES;
    int minutes = MINUTES;
    int secondes = SECONDES;

    //    Alarme
    int alarmeSet[] = {AL_H, AL_M};

    //    Calcul du temps
    unsigned long last = 0;
    // Etat de la trotteuse
    volatile int trotteuseState = 1;


    // Pins
    //    Heures
    int h1 = 3;
    int h2 = 4;
    int h4 = 5;
    int h8 = 6;
    int h16 = 7;
    //    Minutes
    int m1 = 8;
    int m2 = 9;
    int m4 = 10;
    int m8 = 11;
    int m16 = 12;
    int m32 = 13;
    // Secondes
    int s = 1;      // Led trotteuse
    // On/off
    int on_off = 2; // Bouton pour stoper l'alarme
    // alarme
    volatile int alarme = 0; // led d'alarme


    void affichage()
    {
        int minutes_restantes;
        int heures_restantes;
        // Affichage des heures
        if ((heures/16) >=1) { digitalWrite(h16, HIGH);
            heures_restantes = heures%16;} else { digitalWrite(h16, LOW);}
        if ((heures_restantes/8) >=1) { digitalWrite(h8, HIGH);
            heures_restantes = heures%8;} else { digitalWrite(h8, LOW);}
        if ((heures_restantes/4) >=1) { digitalWrite(h4, HIGH);
            heures_restantes = heures%4;} else { digitalWrite(h4, LOW);}
        if ((heures_restantes/2) >=1) { digitalWrite(h2, HIGH);
            heures_restantes = heures%2;} else { digitalWrite(h2, LOW);}
        if ((heures_restantes/1) >=1) { digitalWrite(h1, HIGH);
        heures_restantes = heures%1;} else { digitalWrite(h1, LOW);}

        // Affichage des minutes
        if ((minutes/32) >=1) { digitalWrite(m32, HIGH);
            minutes_restantes = minutes%32;} else { digitalWrite(m32, LOW);}
        if ((minutes_restantes/16) >=1) { digitalWrite(m16, HIGH);
            minutes_restantes = minutes%16;} else { digitalWrite(m16, LOW);}
        if ((minutes_restantes/8) >=1) { digitalWrite(m8, HIGH);
            minutes_restantes = minutes%8;} else { digitalWrite(m8, LOW);}
        if ((minutes_restantes/4) >=1) { digitalWrite(m4, HIGH);
            minutes_restantes = minutes%4;} else { digitalWrite(m4, LOW);}
        if ((minutes_restantes/2) >=1) { digitalWrite(m2, HIGH);
            minutes_restantes = minutes%2;} else { digitalWrite(m2, LOW);}
        if ((minutes_restantes/1) >=1) { digitalWrite(m1, HIGH);
            minutes_restantes = minutes%1;} else { digitalWrite(m1, LOW);}
    }

    void trotteuse()
    {
        // --- Fait clignoter la trotteuse toutes les secondes
        digitalWrite(s, HIGH);
        delay(10);
        digitalWrite(s, LOW);
    }

    void stop_alarme()
    {
        // --- Arrête l'alarme
        digitalWrite(alarme, LOW);
    }

    void alarm()
    {
        // --- Vérifie si c'est l'heure et déclenche l'alarme
        if ((heures == alarmeSet[0])
            && (minutes == alarmeSet[1])
            && secondes == 0) {
            digitalWrite(alarme, HIGH);
        }
    }

    void setup()
    {
        // pin Output
        pinMode(h1, OUTPUT);
        pinMode(h2, OUTPUT);
        pinMode(h4, OUTPUT);
        pinMode(h8, OUTPUT);
        pinMode(h16, OUTPUT);
        pinMode(m1, OUTPUT);
        pinMode(m4, OUTPUT);
        pinMode(m8, OUTPUT);
        pinMode(m16, OUTPUT);
        pinMode(m32, OUTPUT);
        pinMode(s, OUTPUT);
        pinMode(alarme, OUTPUT);
        // bouton
        pinMode(on_off, INPUT);
        // initialisation de la trotteuse
            // et de l'alarme
        digitalWrite(s, LOW);
        digitalWrite(alarme, LOW);
        // Mise en place de l'interruption pour
            // l'arrêt de l'alarme
        attachInterrupt(0, stop_alarme, RISING);
        // premier affichage
        affichage();
    }

    void loop()
    {
        if ((millis()) - last  >= 1000) {
            last = millis();
            trotteuse(); // fait clignoter la trotteuse
            secondes++;  // Incrémentation des secondes
            if (secondes >= 60) {
                minutes++; // 60 secondes : +1 minute
                secondes = 0;
            }
            if (minutes >= 60) {
                heures++; // 60 minutes : +1 heure
                minutes = 0;
            }
            if (heures >= 24){
                heures = 0; // changement de jour
            }
            alarm(); // Vérification pour l'alarme
            affichage(); // affichage de l'heure
        }
    }

La flemme de copier/coller le code ? Télécharge le ici_ !

------------------
Améliore moi ça !!
------------------

Tout le code que j'ai publié dans cet article est sous license
WTFPL_>`_ et que par conséquent, **vous
pouvez l'utiliser absolument comme vous voulez !**

Voilà donc quelques améliorations possibles :

~~~~~~~~~
Trotteuse
~~~~~~~~~

Après quelque jours d'utilisation de l'horloge (et de l'alarme) je me
suis rendu compte que cette trotteuse était vraiment chiante
au possible et méga casse-burnes, euh... *insupportable* !

Ce serait pas une mauvaise idée de la virer !

~~~~~~
Alarme
~~~~~~

A propos d'alarme : si vous avez testé le tout, vous aurez vu qu'a moins
de caler la LED d'alarme à cheval sur vos lunettes, on la voit pas bien.
Plusieurs solutions:

-  Mettre une plusieurs LEDs
-  Essayer d'utiliser un petit HP avec un son super chiant (type buzzer)
-  Faire clignoter cette alarme en externe : genre avec un signal
   d'horloge, une porte AND et la LED en bout, ou autre chose hein !
-  etc...

A vous de tester !

L'autre amélioration possible concerne le code. Pour optimiser un peu et
éviter l'appel à une fonction (``alarm()`` ici), on aurait pu rajouter
une variable ``alarmState`` et n'appeller la fonction que si cette
variable était à 0.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Règlage de l'heure, de l'alarme
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Vous vous sentez en forme ?

Pourquoi ne pas essayer de faire un petit système de règlage de l'heure
avec des potars (sur le port analogique) par exemple. On peut étendre ça
à l'alarme aussi !

PS : Bonne chance pour celui là !

~~~~~~~~~~~~~~~~~~~~~~
Changement de brochage
~~~~~~~~~~~~~~~~~~~~~~

La même qu'avant, mais avec des rangées de résistances DIP :

Avant/Après :

|Résistances séparées| |Résistances DIP|
Vous pourrez voir en même temps le branchement du bouton.

--------------------
Conclusion en carton
--------------------

Voilà, c'est (presque) fini pour l'horloge binaire : rien de très
sorcier donc. Je vous dit *"presque fini"* parce que si j'ai encore du
temps à perdre, j'essairai d'améliorer un peu (notamment le système de
setup pour l'horloge/l'alarme).

En espérant que cet article vous aura à peu près plut ! *(pas facile à
dire ça...)*

.. |En fonctionnement| image:: /static/images/horloge_binaire/PIC_0005.JPG
    :width: 600px
.. |schéma de brochage| image:: /static/images/horloge_binaire/schema.png
    :width: 600px
.. |Explication pour la lecture| image:: /static/images/horloge_binaire/PIC_0009.JPG
    :width: 600px
.. |Résistances séparées| image:: /static/images/horloge_binaire/PIC_0004.JPG
    :width: 600px
.. |Résistances DIP| image:: /static/images/horloge_binaire/PIC_0017.JPG
    :width: 600px
.. _ici: /static/files/horloge_binaire/horloge.pde
.. _WTFPL: http://sam.zoy.org/wtfpl/
