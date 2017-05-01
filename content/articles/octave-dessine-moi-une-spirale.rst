===============================
Octave, dessine moi une spirale
===============================

:date: 2015-01-04 11:28:39
:slug: octave-dessine-moi-une-spirale
:authors: matael
:summary: Un pari débile et un peu de code
:tags: octave, lol, imported

Tout est parti d'un pari stupide avec mon voisin :

    Le premier qui dessine une spirale sur octave a gagné

A l'heure où j'écris ces lignes, je viens juste de réussir et de lui envoyer l'image.

Finalement, si le pari avait peu d'intérêt en soi, j'ai trouvé que c'était rigolo à faire.

Une spirale est un cercle qui s'est oublié
==========================================

Quand on arrête de réfléchir deux minutes, on voit (normalement) qu'une spirale est juste un cercle très long dont le
rayon diminue.

Partant de là, on va d'abord essayer de tracer un cercle.

Sous octave on peut tracer un cercle assez facilement (à droite, le résultat) :

.. image:: /static/images/spirale/cercle.png
    :width: 450px
    :align: right

.. code-block:: matlab

    clear all;
    close all;

    % coordonnées du centre
    x = 0;
    y = 0;

    % rayon
    r = 10;

    t = linspace(0,2*pi,100)';

    cercle_x = r.*cos(t) + x;
    cercle_y = r.*sin(t) + y;

    plot(cercle_x,cercle_y);

Convaincre le cercle de spiraler
================================

Maintenant qu'on a un cercle, il ne reste *plus qu'a* faire varier le rayon ;)

Un jeu d'enfant ;)

On a qu'à boucler sur un vecteur donnant le rayon (appelons le ``r``) et aligner nos coordonnées ``cercle_x`` et ``cercle_y``
pour prendre en compte le rayon *en cours* à chaque point.

On remarque aussi que ``t`` va de 0 à 2pi, ce qui suffit pour tracer un cercle or, une spirale est plus *"longue"* qu'un
cercle, il faudra donc prévoir un moyen de boucler aussi sur ``t`` et de repartir à ``t(1)`` à la fin des 100 points du
``linspace()``.
Pour cela, on va rajouter une variable (je l'ai appellé ``last`` ici) qui variera de 1 à 100 et que l'on utilisera en
indice pour le vecteur ``t``. Lorsque cette valeur atteint 100, on la repasse à 1 etc...

Enfin pour l'évolution du rayon on utilisera un simple ``linspace()`` (ici, 300 valeurs entre 30 et 1).

.. code-block:: matlab

    clear all;
    close all;

    x = 0;
    y = 0;

    t = linspace(0,2*pi,100)';

    cercle_x = [];
    cercle_y = [];
    last = 1;
    for r = linspace(30, 1, 300)
        cercle_x = [cercle_x [r.*cos(t(last)) + x]];
        cercle_y = [cercle_y [r.*sin(t(last)) + y]];
        if last == 100
            last = 1;
        else
            last += 1;
        endif
    endfor

    plot(cercle_x,cercle_y);
    title(["Just a beautiful spiral ;) ["  date() " - " num2str(clock()(4)) ":" num2str(clock()(5)) "]"]);

Notez en même temps que j'ai inséré la date (certes, un peu à l'arrache) dans le titre de la figure.

A gauche, une spirale avec un nombre de points pour le vecteur de rayon trop faible, à droite, la spirale finale :

.. image:: /static/images/spirale/debut_spirale.png
    :width: 400px
    :align: left

.. image:: /static/images/spirale/spirale.png
    :width: 400px
    :align: right

Les images en plus grand peut être ?

- la gauche_
- la droite_

Voilà donc.

Restera ensuite à faire une jolie fonction de tout ça et de la rendre paramétrable et on pourra (enfin) tracer des
spirales facilement !

Note: en zoomant, on apperçoit un petit *décrochage* dans la ligne (à droite), je pense qu'on pourrait gommer ça en
mettant plus de 100 points dans ``t``

.. _gauche: /static/images/spirale/debut_spirale.png
.. _droite: /static/images/spirale/spirale.png
