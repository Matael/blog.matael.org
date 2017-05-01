==========
Processing
==========

:date: 2015-01-04 11:20:58
:slug: processing
:authors: matael
:summary: 
:tags: processing, imported

Un nouveau langage, de nouvelles possibilités, un peu *"d'art"* et pas
mal de trucs marrants en perspective...

Quand j'ai reçu mon arduino, j'ai entendu parler d'un soft appellé
**processing** et qui, selon ce que j'en savais permettait d'interagir
avec l'arduino et de produire des images.

----------
Processing
----------

Récement (la semaine dernière en fait), je me suis penché sur le sujet,
un peu (beaucoup ?) pour le fun et parce que ce truc m'intriguait. De
mes investigations, j'en a ressorti que **processing** n'était pas
simplement un "*soft permettant d'interagir avec l'arduino"* mais aussi
et surtout un langage de programmation à part entière permettant le
rendu d'images (avec où sans l'arduino).

~~~
Qui
~~~

**Processing** a été créé par `une petite équipe de
volontaires`_. D'après `leur
site`_ il y aurait un joli paquet (ils disent
*ten thousand*) d'étudiants, artistes, designers, chercheurs, et autres
passionnés qui l'utilisent.

~~~~
Quoi
~~~~

Processing est un langage complet permettant la génération d'images et
vidéos en 2D/3D. Il dispose d'un IDE créé par les auteurs (rappellant
énormément celui de l'arduino) et de fonctionnalité d'export en applet
(pages web), pdf, png, et autres...

----------
Un langage
----------

Comme tout langage de programmation (et en général) **processing**
demande un apprentissage. Fort heureusement, il reste relativement
classique et sans grande surprise.

Notons toutefois l'étrange tête qu'a une création de tableau :

.. sourcecode:: java

    // créons un tableau de 42 entiers
    int[] tab1 = new int[42];

    // la même, mais en l'initialisant
    int[] tab2 = {1,1,3,5,8,13};

    // enfin, une création de tableau 2D
    int[][] tab3 = new int[42][3];

C'est pour l'instant la seule chose qui m'ait semblée vraiment étrange.

Les programmes **processing** sont stockés dans des fichiers **.pde**...
commme pour l'arduino. Coïncidence ?

Non, mais j'avais mieux à faire que de cherche une réponse.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Structure de base d'un programme
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

La structure la plus basique d'un programme est d'écrire directement les
lignes les unes à la suite des autres...

Si on veut quelque chose d'un peu plus ordonné, on peut utiliser le
squelette suivant :

.. sourcecode:: java

    void setup(){
        // instructions exécutées en premier
    }

    void draw(){
        // le graphe est généré à la fin de cette fonction
    }

~~~~~~~~~~~
Compilation
~~~~~~~~~~~

Il semble que **processing** soit un langage compilé. Ok, no blem...
seulement, il faudra que je me penche sérieusement sur la compilation
depuis la ligne de commande (leur IDE est semblable à celui d'arduino
sur ce point, il est imbuvable).

-------------
Deux exemples
-------------

Pour l'instant, j'essaye de me dépatouiller en partant de zéro.

Les trois programmes suivants sont simples :

-  un classique *Hello World*
-  un truc qui dessine des ellispes sous le pointeur
-  un truc qui trace des points random et les relie par une ligne au
   centre

~~~~~~~~~~~
Hello world
~~~~~~~~~~~

Le programme est suffisament commenté pour être facilement
compréhensible :

.. sourcecode:: java

    void setup(){
            // size règle les valeurs des variables globales
            // height et width. Cela donne la taille de la zone de dessin
        size(100,100);
            // couleur du background (0 -> noir, 255 -> blanc)
        background(0);
            // couleur du pointeur courant
        stroke(255);
    }

    void draw(){
            // affichage du Hello World!
            // text(string txt, int pos_x, int pos_y);
        text("Hello world!", 10, height/2);
    }

Notez que les fonctions ``stroke``, ``background`` et ``fill``
permettent de spécifier aussi des couleurs en code hexa.

Pour lancer ce programme, copiez le dans l'IDE et appuyez sur *CTRL-R*
(ou le bouton play hein...).

~~~~~~~~~~~
Hello Mouse
~~~~~~~~~~~

La réaction à la souris est super simple

.. sourcecode:: java

    void setup(){
        size(650,500);
    }

    void draw(){
        if(mousePressed){ // si le bouton de la souris est appuyé
            fill(0); // on passe en noir
            // et on dessine une ellipse horizontale  
            ellipse(mouseX, mouseY, 80,40);
        } else { // sinon
            fill(255); // on passe en blanc
            // et on dessine une ellipse verticale
            ellipse(mouseX, mouseY, 40,80); 
        }
    }

~~~~~~~~
L'étoile
~~~~~~~~

Là c'est un peu plus velu, le code est tout de même suffisament commenté
pour que ce soit compréhensible :

.. sourcecode:: java

    int nb_points = 142;    // nombre de points à tracer   
    int size_of_points = 2; // taille x et y d'un point
    boolean first = true;   // premiere iteration de la boucle
    float x,y;              // coordonnée du point courant
    int nb_passages = 0;    // compteur -> nb_points


    void setup(){
        // initialisation de la zone de dessin
        size(542, 542);      // taille de la zone
        background(#1C1C1C); // couleur du BG
        stroke(#064C90);     // couleur des lignes
        fill(#064C90);       // couleur des ellipses

        // la fonction draw() doit être exécutée en boucle
        loop();
    }


    void draw(){
        // si on est à la premiere itération
        if(first) {
            // traçage de l'ellipse centrale
            ellipse(height/2, width/2, size_of_points, size_of_points);
            first = false;
        }

        // définition des points  
        if (nb_passages <= nb_points) {
            x = random(1,542); // abscisses
            y = random(1,542); // ordonnées

            // on trace le point...
            ellipse(x, y, size_of_points, size_of_points);
            // et la ligne.
            line(width/2,height/2,x,y);
            nb_passages++;
        }
        // on attend un peu, c'est joli
        delay(25);
    }

~~~~~~~~~~~~~~~~~~~~
La version qui bouge
~~~~~~~~~~~~~~~~~~~~

Enfin, le bonus du jour, une version qui bouge :

.. sourcecode:: java

    int nb_points = 100;    // le nombre de points
    int step = 7;           // combien de points à rafraichir
    boolean first = true;   // premiere ité de la boucle
    int ellipse_size = 5;   // taille d'un point
    int[][] points = new int[nb_points][2]; // tableau de points

    // initialisation des points
    void init_points(){
        for (int i = 0; i <nb_points; i++){
            points[i][0] = int(random(1, width-1));
            points[i][1] = int(random(1,height-1));
        };
    }

    // redessiner l'image
    void redraw_frame(){
        background(#101010); // couleur du bg

        // centre
        ellipse(height/2, width/2, ellipse_size, ellipse_size);

        // points and lines
        for (int i=0; i <nb_points; i++){
            ellipse(points[i][0], points[i][1], ellipse_size, ellipse_size);
            line(height/2, width/2, points[i][0], points[i][1]);
        }
    }

    // modifier des points au pif dans le tableau
    void modify_points(){
        int start_point = int(random(nb_points-step));
        int end_point = start_point + step;
        for (int i=start_point;i<=end_point;i++){
            points[i][0] = int(random(1, width-1));
            points[i][1] = int(random(1, height-1));
        }
    }


    void setup(){
        size(600,600);
        stroke(#002259);
        fill(#064C90);
        loop();
    }


    void draw(){
        if (first){
            init_points();
            first = false;
        }
        redraw_frame();
        modify_points();
        delay(10);
    }

----------
Conclusion
----------

**Processing** semble intéressant pour pas mal de choses. Il reste très
facile à prendre en main et proche des autres langages.

Sous peu j'essaierais d'utiliser les fonctions de plot 3D pour voir à
quel point on peut pousser la chose. De même, j'aimerais tenter l'export
video et pdf et l'import video/photo.

Enfin, il serait sympa de pouvoir générer des graphes plus poussés et de
gérer I/O clavier et arduino.

A plus tard, pour de nouvelles aventures !

.. _une petite équipe de volontaires:  http://processing.org/about/people/
.. _leur site: http://processing.org/
