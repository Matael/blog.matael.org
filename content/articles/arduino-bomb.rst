============
Arduino Bomb
============

:date: 2015-01-04 11:28:39
:slug: arduino-bomb
:authors: matael
:summary: Defuse me if you can (fr)
:tags: arduino, imported

Il y a peu, je suis tombé sur `cette page`_.

Même si je n'avais pas envie de refaire une horloge complète, avec affichage etc..., je me
suis dit qu'il pouvait être sympa d'essayer de recoder juste la fonctionnalité de *"bombe"*...

Finalement, le script s'est fait sans soucis et j'ai pu toucher à un autre projet que celui
que je finalise en ce moment et dont je parlerais bientôt.

    Ceci n'est **pas** une véritable bombe (et heureusement).
    Il n'y a ici **aucun danger**.
    Ne soyez pas stupide, n'emmenez pas un truc comme ça (encore plus si vous y mettez des
    afficheurs) n'importe où.


Montage
=======

Le montage en lui même est plutot simple :

.. image:: /static/images/defuse/defuse.png
    :width: 300px
    :align: right

On voit en noir la masse, en rouge le +VCC qui sert pour le bouton de déclenchement du
compte à rebours et en jaune les fils permettant le "désamorçage" ou le déclenchement de la
*"bombe"*.

J'ai utilisé une LED RGB pour afficher (en quelque sorte) le compte à rebours et l'état de
la *"bombe"*.
Voilà les signification :

- clignote en **bleu** toutes les secondes environ pendant le compte à rebours
- s'allume en **vert** pendant une seconde si la *"bombe"* est désamorcée
- idem en **rouge** si la bombe explose

Par convention, nous prendrons les pins suivantes comme référence :

Vert
    pin 3
Bleu
    pin 4
Rouge
    pin 5

Le bouton est relié à l'entrée 2 de l'arduino, soit **INT0**.

Pour les fils de la *"bombe"*, nous les relions des pins 6 à 9 vers les pins 10 à 13.
Les premières sont en OUT tandis que les secondes sont en OUT.


Programme
=========

Le programme lui-même est sans difficulté, simplement il faut connaitre les fonctions 
``randomSeed`` et ``random`` qui permettent d'initialiser et d'utiliser le générateur de 
nombres aléatoires.

Le squelette est simple :

.. code-block:: c

    // Définition des couleurs pour la LED
    #define R 5
    #define G 3
    #define B 4

    // Définition des fils
    #define F1 6
    #define F2 7
    #define F3 8
    #define F4 9

    // Définition du bouton : INT0 ;)
    #define BUTTON 0

    // tableau contenant les numéros de pins OUT de la bombe
    volatile int F[4] = {F1, F2, F3, F4};

    // la bombe est elle activée ?
    volatile int bomb = 0;

    // utile pour après
    volatile int boom, ouf;

    void setup()
    {
        // activation des pins en IN/OUT
        int i;
        for (i = 0; i < 4; i++) {
            // 6 7 8 9 à OUT
            pinMode(F[i], OUTPUT);
            // 10 11 12 13 à IN
            pinMode(F[i]+4, INPUT);
            // On passe les cables au niveau haut
            digitalWrite(F[i], HIGH);
        }

        // On passe à OUT les pins de la LED
        pinMode(R, OUTPUT);
        pinMode(G, OUTPUT);
        pinMode(B, OUTPUT);

        // Init de la random à partir d'une
        // pin analogique non connectée
        randomSeed(analogRead(0));

        // mise en place de l'interruption
        attachInterrupt(BUTTON, activate_bomb, RISING);
    }

Pour la ``loop``, elle sera simple :


.. code-block:: c

    void loop()
    {
        // la bombe est elle activée ?
        if (bomb) {

            // c'est parti !
            int defused = critical_sequence();

            if (defused) { // si le désamorçage a réussi
                // on passe la LED en vert
                digitalWrite(G, HIGH);
            } else { // sinon...
                // ... en rouge !
                digitalWrite(R, HIGH);
            }

            // on attend un peu et on éteind la LED
            delay(1000);
            digitalWrite(G, LOW);
            digitalWrite(R, LOW);

            // On désactive la bombe, tu t'es bien battu
            bomb = 0;
        }
    }

De là, nous savons qu'il y aura deux autres fonctions :

- ``critical_sequence`` pour le *"jeu"* lui même qui devra renvoyé 0 pour une explosion et
  1 pour un désamorçage
- ``activate_bomb`` pour l'activation de l'engin

Routine d'interruption : ``activate_bomb``
------------------------------------------

La routine d'interruption sera déclenchée par appui sur le bouton et doit activer la *"bombe"*.

Elle doit donc :

- choisir un fil au hasard pour le désamorçage
- idem pour l'explosion instantanée
- passer ``bomb`` à 1

La fonction random va nous être utile ici, voilà deux exemples de son utilisation

.. code-block:: c

    randomSeed(analogRead(0)); // Init

    random(10);     // un nombre entre 0 et 9
    random(30, 43); // un nombre entre 30 et 42

Là encore, la fonction elle même reste simple :

.. code-block:: c

    void activate_bomb(){
        // routine d'interruption pour activer la bombe

        // Choisir le fil qui désamorce
        ouf = F[random(4)]+4;

        // Choisir le fil qui fera tout exploser
        do {
            boom = F[random(4)]+4;
        } while (ouf == boom); // en s'assurant qu'il est différent du premier

        // Activation !
        bomb = 1;
    }

Voilà donc pour l'interruption, à la prochaine itération de ``loop``, la *"bombe"* se lancera réellement.

La bombe : ``critical_sequence``
--------------------------------

La *"bombe"* elle même doit :

- faire blinker la LED en bleu une fois toute les secondes (comme demandé)
- vérifier quels fils sont coupés et passer le système dans l'état voulu au besoin
- si les fils de désamorçage et d'explosion sont coupés en même temps, faire exploser la *"bombe"* (parce que sinon, c'est pas du jeu).
 
Somme toute, c'est une boucle, et deux conditions :

.. code-block:: c

    int critical_sequence() {
        // Essaye donc de désamorcer ;)!

        int i = 10; // T'auras 10s ;)
        while (i>=0) {
            
            // On fait clignoter en bleu
            digitalWrite(B, HIGH);
            delay(100);
            digitalWrite(B, LOW);

            
            // si le fil d'explosion est coupé :
            if (digitalRead(boom) == LOW) {
                return 0; // on renvoie 0
            }

            // si le fil de désamorçage est coupé :
            if (digitalRead(ouf) == LOW) {
                return 1; // on renvoie 1
            }

            // on attends 450 millis
            delay(450);

            // on reteste                    
            if (digitalRead(boom) == LOW) {
                return 0;	
            }

            if (digitalRead(ouf) == LOW) {
                return 1;
            }

            delay(450);	

            // et on décrémente
            i--;
        }
        // si la bombe n'est pas désamorcée au bout du temps,
        // on la fait exploser
        return 0;
    }

La raison pour laquelle je fais le test deux fois par boucle est simple : ça permet au
programme d'être plus fluide et plus réactif quand un fil est enlevé.

Code complet
------------

Pour les moins courageux, le code complet est `disponible ici`_.
Notez que depuis la version 1.0.0 d'Arduino, les sources portent l'extension *.ino*, le
*.pde* étant réservé à Processing_ désormais.

Conclusion
==========

Voilà donc un mini-jeu débile à base d'arduino. 

Histoire de pimenter un peu le jeu, on peut envisager de modifier un peu le programme pour
qu'un des deux fils inutilisés ait pour effet de supprimer 3 secondes d'un coup au compte
à rebours. 
Il suffirait de modifier un peu notre fonction d'activation pour rajouter une variable :
``too_bad`` qui pointerait vers un des fils restants par exemple.
Il faudrait aussi toucher un peu à ``critical_sequence`` et ajouter ça aux tests :

.. code-block:: c

    if (digitalRead(too_bad) == LOW) {
        i -= 3;	
    }

Voilà donc de quoi occuper les gosses pendant un petit moment ;)


.. _cette page: http://nootropicdesign.com/defusableclock/
.. _disponible ici: /static/images/defuse/defuse.ino
.. _Processing: http://processing.org
