============
Random balls
============

:date: 2015-01-04 11:20:58
:slug: random-balls
:authors: matael
:summary: 
:tags: processing, imported

Comme je l'avais dit dans un `billet
précédent`_, j'ai continué à tester
**processing**, voici donc un autre de mes essais...


------
L'idée
------

J'ai voulu tester les fonctions d'**export png** et de **réaction au
clavier** ainsi que d'utiliser des couleurs **rgba** et de jouer sur la
**superpositions des couches de dessin**.

~~~~~~~~~~~~~~~
La figure visée
~~~~~~~~~~~~~~~

Une figure répondant à ce que j'attend serait un truc comme ça :

|Exemple de figure finale|


Vous en trouverez d'autre dans les liens en bas.

*************
Des boules...
*************

Le but est d'arriver à une image où sont posées des *"boules"* (notées
*balls* dans le programme) de ce genre :

|Ball|

**Note :** même si ça se voit pas des masses sur l'image, la partie
bleue de ces balls n'est **pas opaque** mais transparente : sinon, c'est
moche quand 2 balls se chevauchent.

****************
...et des lignes
****************

Les centres (le petit rond blanc au centre) de boules proches doivent se
relier par une ligne blanche passant **sous** les autres boules (sinon,
on voit plus rien, croyez moi).

Voilà à quoi sont censée ressembler 2 balls liées :

|Balls liées|

~~~~~~~~~~~~~~~~~~
Référence en local
~~~~~~~~~~~~~~~~~~

J'ai aussi découvert ça en cherchant un moyen de compiler mes programmes
en ligne de commande (ça par contre, je l'ai pas trouvé) : on a une
copie de la référence en ligne au format HTML dans le tarball qu'on
télécharge sur leur site. Vous pourez la trouver là :

.. sourcecode:: bash

    processing/modes/java/reference/index.html

-------------------
Le code fractionné!
-------------------

On va procèder par étapes histoire que tout le monde suive, mais
globalement, y'a rien de super compliqué

~~~~~~~~~~~~~~~~~~
Variables globales
~~~~~~~~~~~~~~~~~~

Je sens que certains vont bondir au plafond, seulement, j'ai pas envie
de m'emmerder avec des prototypes super longs. On va donc utiliser
quelques variables globables pour nous simplifier la tache :

.. sourcecode:: java

    int nb_balls = 90;       // Nombre de balls à dessiner
    int ball_size_min = 25;  // taille minimum d'une boule (le centre fait 10*10)
    int ball_size_max = 225; // taille max
    float line_factor = 1.1; // facteur de proximité

    // le tableau qui contiendra les coordonnées et la taille de chaque ball
    int[][] balls = new int[nb_balls][3];

Le **facteur de proximité** nous permettra de savoir si deux boules sont
proches ou non.

~~~~~~~~~
``setup``
~~~~~~~~~

La fonction ``setup`` est triviale :

.. sourcecode:: java

    void setup(){
        size(900,450); // la zone de dessin fait 900*450
        noLoop();      // on exécute draw() qu'une fois de suite
        noStroke();    // on n'affiche pas de pointeur
    }

~~~~~~~~~~~~~~
``init_balls``
~~~~~~~~~~~~~~

On va initialiser notre tableau de balls à travers une fonction :
``init_balls()``.

.. sourcecode:: java

    void init_balls(){
        for (int i = 0; i < nb_balls; i++){
            balls[i][0] = int(random(0, width));  // x pos
            balls[i][1] = int(random(0, height)); // y pos
            balls[i][2] = int(random(25,125+1));  // taille de la ball
        }  
    }

~~~~~~~~~~~~~
``draw_ball``
~~~~~~~~~~~~~

Les fonctions, caybien, alors on va en faire une pour tracer les balls
et rendre le code un peu plus lisible.

.. sourcecode:: java

    void draw_ball(int x, int y, int ball_size){
        fill(255); // remplissage en blanc
        ellipse(x, y, 5, 5); // on trace le centre
        fill(13, 15, 56, 70); // remplissage en bleu translucide
        ellipse(x, y, ball_size, ball_size); // on trace l'extérieur de la ball
    }

~~~~~~~~~~~~~~
``draw_lines``
~~~~~~~~~~~~~~

Cette fonction est probablement la plus compliquée. En effet, on a dit
qu'on ne voulait tracer des lignes qu'entre les balls **proches**.

On a défini tout à l'heure, une variable ``line_factor`` et on a dit
qu'elle servirait pour *savoir si deux boules sont proches ou non*. On
va considérer qu'une ball est proche d'une autre si **la distance entre
leurs centres est inférieure ou égale à
``line_factor*taille de la première``**.

Nous savons récupérer la taille d'une ball, reste à calculer la distance
entre 2 balls. Voilà la formule pour la distance entre 2 points
(pythagore powaa) :

.. image:: /static/images/random_balls/formule_distance.png
    :align: center
    :width: 300px

Voilà le code de cette fonction :

.. sourcecode:: java

    void draw_lines(){
        int x; // x pos pour l'iteration
        int y; // y pos ...
        int s; // size ...
        float distance; // distance ...
        for (int i=0; i < nb_balls; i++){
            // pour chaque ball on récupère coordonnées et taille
            x = balls[i][0];
            y = balls[i][1];
            s = balls[i][2];
            for (int j=0; j <nb_balls; j++){
                // pour chaque ball, on calcule la distance avec la première
                distance = sqrt(pow(x -balls[j][0],2) + pow(y - balls[j][1],2));
                // si elles ne sont pas exactement superposée et qu'elles sont proches
                if(!((x == balls[j][0]) && (y == balls[j][1])) && (distance <= s*line_factor)){
                    // on trace la ligne entre leurs centres
                    stroke(255);
                    line(x,y,balls[j][0], balls[j][1]);
                    noStroke();
                }
            }
        }
    }

~~~~~~~~~~~~~~~~~~~~~~~~~
Combo ``draw_full_frame``
~~~~~~~~~~~~~~~~~~~~~~~~~

Cette fonction se charge de dessiner l'image complète (bakground + balls
+ lines). Elle n'est qu'un combo des autres, dans le bon ordre :

.. sourcecode:: java

    void draw_full_frame(){
        background(70); // d'abord le BG
        draw_lines();   // puis les lignes
        // enfin, les balls
        for (int i=0; i < nb_balls; i++){
            draw_ball(balls[i][0], balls[i][1], balls[i][2]);
        }
    }

L'ordre est très important car les dessins se superposent. On cherche
bien à obtenir la superposition suivante :

::

    +-----------------------+  A
    |        BALLS          |  |
    +-----------------------+  |
    +-----------------------+  | Sens d'appel des
    |        LINES          |  |   Fonctions
    +-----------------------+  |
    +-----------------------+  |
    |      BACKGROUND       |  |
    +-----------------------+  |

~~~~~~~~~~~~~~~~~~~~~~
La réaction au clavier
~~~~~~~~~~~~~~~~~~~~~~

Si vous vous souvenez bien, un des codes sources de l'article précédent
contenait :

.. sourcecode:: java

    if (mousePressed){
        // ...
    }

Cette conditionnelle permettait de réagir au clic de souris.

Il faut savoir deux choses :

#. ``if (keyPressed) {}`` permet de réagir aux frappes sur le clavier
#. On peut utiliser des fonctions plutot que de simples conditionnelles
   pour réagir aux évènements. Par exemple :

.. sourcecode:: java

   void mousePressed(){ // truc à faire après un clic }

   // et

   void keyPressed(){ // truc à faire après la frappe }

Bien entendu, il faut pouvoir réagir **en fonction de la touche ou du
bouton appuyé**, **procssing** met donc à notre disposition 2 variables
: ``mouseButton`` et ``key`` qui contiennent respectivement :

-  le bouton utilisé : ``LEFT``, ``CENTER`` ou ``RIGHT``
-  la touche enfoncé : un caractère de la table ASCII

Notons que des fonctions du genre existent pour le relachement d'une
touche/ d'un bouton, un mouvement de la souris, et mouvement avec
maintien (drag).

Voici donc la fonction pour réagir au clavier :

.. sourcecode:: java

    void keyPressed(){
        if (key == 'r' || key == 'R'){
            redraw(); // on génére une nouvelle figure
        } else if (key == 's' || key == 'S'){
            saveFrame("frame-####.png"); // on enregistre la figure courante
        }
    }

Vous aurez compris le comportement :

-  appui sur **r** ou **R** : nouvelle figure aléatoire
-  appui sur **s** ou **S** : enregistrement de la figure courante

**********
``redraw``
**********

Cette fonction ré-éxecute la fonction ``draw()`` une fois (souvenez
vous, on avait supprimé l'exécution en boucle dans ``setup()``.

*************
``saveFrame``
*************

``saveFrame`` et sa copine ``save`` permettent d'enregistrer l'image
courante. La différence ?

``save`` enregistre une et une seule image (elle détruit la précédente
si on l'appel deux fois ou plus).

``saveFrame`` enregistre autant de nouvelle images qu'il faut en les
numérotant à la place des ``####``.

~~~~~~~~
``draw``
~~~~~~~~

La fonction ``draw`` est plus que triviale. Elle se content
d'initialiser le tableau et de tracer la première frame.

.. sourcecode:: java

    void draw(){
        init_balls();
        draw_full_frame();
    }

----------------
Le code complet!
----------------

Le code tout à la suite :

.. sourcecode:: java

    int nb_balls = 90;       // Nombre de balls à dessiner
    int ball_size_min = 25;  // taille minimum d'une boule (le centre fait 10*10)
    int ball_size_max = 225; // taille max
    float line_factor = 1.1; // facteur de proximité

    // le tableau qui contiendra les coordonnées et la taille de chaque ball
    int[][] balls = new int[nb_balls][3];

    void setup(){
        size(900,450); // la zone de dessin fait 900*450
        noLoop();      // on exécute draw() qu'une fois de suite
        noStroke();    // on n'affiche pas de pointeur
    }

    void init_balls(){
        for (int i = 0; i < nb_balls; i++){
            balls[i][0] = int(random(0, width));  // x pos
            balls[i][1] = int(random(0, height)); // y pos
            balls[i][2] = int(random(25,125+1));  // taille de la ball
        }  
    }

    void draw_ball(int x, int y, int ball_size){
        fill(255); // remplissage en blanc
        ellipse(x, y, 5, 5); // on trace le centre
        fill(13, 15, 56, 70); // remplissage en bleu translucide
        ellipse(x, y, ball_size, ball_size); // on trace l'extérieur de la ball
    }

    void draw_lines(){
        int x; // x pos pour l'iteration
        int y; // y pos ...
        int s; // size ...
        float distance; // distance ...
        for (int i=0; i < nb_balls; i++){
            // pour chaque ball on récupère coordonnées et taille
            x = balls[i][0];
            y = balls[i][1];
            s = balls[i][2];
            for (int j=0; j <nb_balls; j++){
                // pour chaque ball, on calcule la distance avec la première
                distance = sqrt(pow(x -balls[j][0],2) + pow(y - balls[j][1],2));
                // si elles ne sont pas exactement superposée et qu'elles sont proches
                if(!((x == balls[j][0]) && (y == balls[j][1])) && (distance <= s*line_factor)){
                    // on trace la ligne entre leurs centres
                    stroke(255);
                    line(x,y,balls[j][0], balls[j][1]);
                    noStroke();
                }
            }
        }
    }

    void draw_full_frame(){
        background(70); // d'abord le BG
        draw_lines();   // puis les lignes
        // enfin, les balls
        for (int i=0; i < nb_balls; i++){
            draw_ball(balls[i][0], balls[i][1], balls[i][2]);
        }
    }

    void keyPressed(){
        if (key == 'r' || key == 'R'){
            redraw(); // on génére une nouvelle figure
        } else if (key == 's' || key == 'S'){
            saveFrame("frame-####.png"); // on enregistre la figure courante
        }
    }

    void draw(){
        init_balls();
        draw_full_frame();
    }

Pour les flemmards du copier-coller : `das
code`_ !

----------
Conclusion
----------

Voilà donc un second article sur **processing** qui s'achève avec
l'exploration que nouvelles foncions...

J'espère au moins que ça vous aura appris des trucs ;)

Une amélioration faisable au niveau de ce code serait de le rendre plus
intéractif. On pourrait considérer chaque point commme un objet et
modifier leur taille au passage de la souris par exemple.

Je pense qu'en cherchant bien, on trouverait plein d'autres choses
inutiles et passionantes à ajouter au programme...

Bonne chance !

-------------
Quelques docs
-------------

Voilà les codes utilisés pour la génération des 2 premières images et un
lien vers le code final :

-  Code Final `das code`_
-  `Ball Alone`_
-  `Ball Linked`_
-  `Exemple de figure finale`__
-  `Un autre exemple de figure finale`__

.. |Exemple de figure finale| image:: /images/random_balls/final1.png
    :width: 600px
.. |Ball| image:: /images/random_balls/ball_alone.png
    :width: 300px
.. |Balls liées| image:: /images/random_balls/balls_linked.png
    :width: 300px

.. _billet précédent:  /writing/processing
.. _das code: /static/files/random_balls/random_balls.pde
.. _Ball Alone: /static/files/random_balls/alone.pde
.. _Ball Linked:  /static/files/random_balls/linked.pde
.. __: /static/images/random_balls/final2.png_
.. __: /static/images/random_balls/final3.png_
