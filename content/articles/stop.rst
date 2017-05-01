====
Stop
====

:date: 2015-01-04 11:20:57
:category: imported
:slug: stop
:authors: matael
:summary: 
:tags: arduino

Comment gérer tout ce qui est nécessaire et réagir aux nouvelles données
avec un microcontrôleur ?

Dans la programmation d'une application pour microcontrôleur, on ne va
pas loin si on doit vérifier en permanence l'état des différentes pins.
Certains changement d'état des pins doivent bénéficier d'un traitement
rapide, dès leur apparition. Pour gérer de tels comportements, exécuter
le programme principal et réagir au quart de tour si besoin, on a mis en
place sur les microcontrôleurs un système d'**interruptions** !

----------
Pourquoi ?
----------

Comme je le disais tout de suite, au cours de l'éxécution d'un
programme, on peut (en fait, on en a très souvent besoin) de réagir à un
changement d'état sur une (ou plusieur) des pins du micro-controleur.

---------------------
Qu'est ce que c'est ?
---------------------

Apellées en anglais IRQ (*interruption request* ou *demande
d'interruption*), les interruptions matérielles sont provoquées par un
changement détat sur une des lignes I/O **matérielles** d'un
microcontrôleur. Les interruptions peuvent aussi être de nature
logicielles (souvent apellées *exceptions* en informatiques). On lie la
détection (automatique) de ce changement d'état à l'exécution d'une
fonction qui doit être minimaliste pour ne pas perturber l'éxécution du
programme principal.

-------------------------
Utilité des interruptions
-------------------------

Imaginez que, dans l'attente d'un changement de niveau sur une des pins
du microcontrôleur, vous dussiez insérer entre chaque instruction du
programme un truc du genre :

.. sourcecode:: c

    if (ancien_etat != digitalRead(numero_de_pin))
    { 
        ancien_etat = digitalRead(numero_de_pin);
        fonction();
    }

Pour vérifier dès que possible si un changement d'état a eu lieu...
Autant vous dire que votre programme ne va pas être très lisible et
surtout sera très peu efficace !!

En fait, ce genre de structures étaient souvent rassemblées (le sont
toujours) dans ce que l'on appelle une **polling loop** (boucle de
consultation). Les principaux inconvénients de cette boucle sont simples
à comprendre : elle est longue à entreprendre et monopolise une mémoire
impressionnante ! En effet, il faut, à intervalles réguliers, vérifier
les états logiques des pins à surveiller, déclencher une fonction si
nécessaire, et stocker les états pour pouvoir comparer à la prochaine
itération de la boucle...

Les interruptions sont alors **la** bonne idée ! Implémentées comme il
faut, elle permettent d'éxécuter une **routine de gestion
d'interruption** (en anglais *interrupt handler*) après avoir sauvegardé
le contexte d'éxécution du programme principal puis de reprendre cette
dernière comme si de rien était. La routine de gestion d'une
interruption doit toutefois s'éxécuter de manière suffisament rapide
pour que son fonctionnement soit quasi transparent.

----------------------------
Quand peut on les utiliser ?
----------------------------

Les interruptions sont utiles dès qu'un état précis du sytème requiert
une réaction **rapide**. Le déclenchement d'une interruption est
indépendant de l'éxécution du programme principal (il est toutefois
possible de désactiver la gestion des interruptions pour certaines
partie d'un programme ne pouvant souffrir de retard). Les interruptions
peuvent par exemple servir pour la gestion d'un évènement important (fin
d'un transfert, apparition d'une conection, approche d'un obstacle dans
le cas d'un robot, etc...) ou la réaction à un acte de l'utilisateur.

Notez enfin que sur les plus gros sytèmes (les ordinateurs par exemple),
la gestion et le déclenchement des interruptions disposent de circuits
dédiés, au moins pour leur hierarchisation (parfois pour leur
traitement).

--------------
Et l'arduino ?
--------------

L'arduino est une plaque programmable basé sur un microcontroleur et de
fait propose une gestion des interruptions qui, même si elle reste très
imparfaite, est toujours meilleure que celle proposé par d'autres
systèmes programmables. Des langages de bas niveau comme l'Assembleur
proposent la meilleure gestion et la plus grande flexibilité pour les
interruptions. Ce sont en effet des traitements très proches de la
partie *physique* d'un système. Dans les langages de plus haut niveau on
peut générer des interruptions logiciellles sous la forme
d'*exceptions*.

~~~~~~~~~
Fonctions
~~~~~~~~~

Dans le système de gestion de l'arduino, quatre fonctions sont dédiées
aux interruptions : ``attachInterrupt()``, ``detachInterrupt()``,
``interrupts()`` et ``noInterrupts()``.

*****************
attachInterrupt()
*****************

Cette fonction permet de lier le déclenchement d'une interruption à un
évènement sur une pin. Elle s'utilise comme suit :

.. sourcecode:: c

    attachInterrupt(num, fonction, mode);

Où :

-  ``num`` est le numéro de l'entrée d'interruption
-  ``fonction`` est la fonction à executer (routine d'interruption)
-  ``mode`` est la condition de déclenchement

Ce troisième paramètre (``mode``) peut prendre 4 valeurs différentes :

-  ``LOW`` : interruption lorsque la pin est au niveau logique bas
-  ``CHANGE`` : interruption lors d'un changement de valeur sur la pin
   (montée ou descente, indifférement)
-  ``RISING`` : interruption lors d'un passage d'un niveau à un niveau
   supérieur (front montant)
-  ``FALLING`` : interruption lors d'un passage d'un niveau à un niveau
   inférieur (front descendant)

Le choix du mode de déclenchement dépend du comportement que l'on
souhaite obtenir. Pour un poussoir par exemple, les modes ``RISING`` et
``FALLING`` sont sympas... (regardez dans l'exemple)

Notez enfin que seules deux valeurs sont possibles pour ``num`` (avec
l'arduino Uno) : 0 ou 1. En effet, ce modèle ne dispose que de 2 pins
gérant les interruptions. Il s'agit des pins 2 (entrée d'interruption 0)
et 3 (entrée d'interruption 1). Je vous avais prévenus, l'arduino reste
limité du coté des interruptions (l'Arduino Mega 2650 dispose de plus
nombreuses entrées d'interruption).

Dernières précisions : toutes les variables utilisées dans les routines
de gestion des interruptions doivent être déclarées avec le mot-clé
``volatile``. De même, il est impossible d'utiliser des fonctions comme
``delay()`` dans une routine d'interruption : Le décompte des
microsecondes n'a pas lieu pendant ces fonctions et ``delay()`` est
basée sur ce décompte.

*****************
detachInterrupt()
*****************

Aussi bizarre que cela puisse paraître, cette fonction fait l'inverse de
la première. Après avoir validé la génération d'interruptions avec
``attachInterrupt()``, on peut annuler cette action avec
``detachInterrupt(num)`` (là encore, ``num`` est le numero de l'entrée
d'interruption).

*****************************
interrupts() & noInterrupts()
*****************************

Il s'agit des deux fonctions permettant d'activer ou de désactiver la
génération d'interruptions. Il est parfois nécessaire qu'une partie du
programme se déroule sans perturbations et on peut avoir besoin de
supprimer les interruptions à ce moment là : c'est le role de
``noInterrupts()``.

La fonction ``interrupts()`` permet de les réactiver.

~~~~~~~
Exemple
~~~~~~~

Voyons, histoire de bien comprendre, un exemple en carton.

*Le contexte : L'arduino commande un petit chenillard (va et viens sur
des leds)*

*Le but : Mettre le pause le chenillard lors de l'appui sur le poussoir
et le réactiver au second appui, etc...*

*******
Le code
*******

Le code source est relativement simple à comprendre (surtout commenté de
la sorte !) :

.. sourcecode:: c

    // Nombre de leds
    #define NOMBRELEDS  8

    // Leds (dans un tableau parce que c'est plus simple à parcourir)
    volatile int leds[] = {4,5,6,7,8,9,10,11};

    // Pin du Bouton
    int buttonPin = 2;

    // Durée du delay
    int timer= 100;

    // Marche/Arret
    volatile int pauseState = 0;

    // Routine de gestion d'interruption
    void pause()
    {
        pauseState = 1 - pauseState;
    }

    void setup()
    {
        int i;
        // On déclare les pins des LEDs en sortie
        for (i = 0; i < NOMBRELEDS; i++) {
            pinMode(leds[i], OUTPUT);
        }
        // ... et le bouton en entrée
        pinMode(buttonPin, INPUT);
        // On lie l'interruption à la pin qui va bien (pin 2 -> inter0)
        attachInterrupt(0, pause, RISING);
    }

    void loop()
    {
        int i; // variable d'itération
        digitalWrite(leds[0], HIGH);
        for (i = 0; i < NOMBRELEDS; i++) {
            // Si on est en mode pause : on attend
            while (pauseState == 1) { delay(1); }
            delay(timer);
            digitalWrite(leds[i-1], LOW);
            digitalWrite(leds[i], HIGH);
        }
        // et on repart dans l'autre sens !
        for (i = NOMBRELEDS -1 ; i >= 0; i--) {
            while (pauseState == 1) { delay(1); }
            delay(timer);
            digitalWrite(leds[i+1], LOW);
            digitalWrite(leds[i], HIGH);
        }
    }

Encore une fois : vous pouvez télécharger `le
code`_ !

**********
Le circuit
**********

|schéma|
Vous ne voyez pas le SVG ? Voilà deux autres versions :

-  Fritzing_
-  PNG_

Les résistances pour les LEDs sont des 220Ohms et celle du bouton est une
470Ohms...

Y'a plus qu'a tester !!

... Et à constater que le bouton fonctionne !!

.. |schéma| image:: /static/images/stop/stop.svg
    :width: 600px
.. _le code: /static/files/stop/stop.pde 
.. _Fritzing: /static/files/stop/stop.fz
.. _PNG:  /static/images/stop/stop.png
