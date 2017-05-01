=======
Polyfit
=======

:date: 2015-01-04 11:28:38
:slug: polyfit
:authors: matael
:summary: Régression linéaire
:tags: octave, breve, imported

Un billet court pour parler de régression linéaire.

Il y a peu, je suis tombé sur une série de mesure comme ça ::

    10  4.61 
    15  2
    20  1.3  
    30  0.94 
    40  0.78 
    50  0.7
    60  0.67
    70  0.64 
    80  0.63 
    90  0.62 
    100 0.61

Ce qui dans Octave m'a donné un joli tableau : 

.. sourcecode:: matlab

    mes_data = [10 4.61  ; 15 2 ; 20 1.3   ; 30 0.94  ; 40 0.78  ; 50 0.7 ; 60 0.67 ; 70 0.64  ; 80 0.63  ; 90 0.62  ; 100 0.61];

De là, j'en tire les coordonnées de mes points de mesure et je les affiche sans problème :

.. sourcecode:: matlab

    x = mes_data(:,1);
    y = mes_data(:,2);
    plot(x,y,'b+');
    grid on;

Ce qui me donne le graphe ci-contre (avant_).

.. image:: /static/images/polyfit/avant.png
    :width: 300px
    :align: right

**Note :** le troisème argument de ``plot()`` (``'b+'``) permet de spécifier la couleur (bleu) et forcer l'utilisation de croix pour les points, sans les relier.
On procède ainsi car il s'agit d'une série de mesure.


Vient ensuite la partie intéressante : mon système travaille surtout dans la partie basse de cette courbe et il serait intéressant de la modéliser.

Les points sont presque en ligne, on peut donc envisager une régression linéaire, et c'est là que ``polyfit()`` fait son entrée :


.. sourcecode:: matlab

    coefs = polyfit(x(4:11,1),y(4:11,1),1);

    hold on; % pour ne pas remplacer la courbe existante
    plot(x(4:11,1), coefs(2)+coefs(1)*x(4:11,1),'r');

.. image:: /static/images/polyfit/apres.png
    :width: 300px
    :align: right


Et on obtient le graphe ci-contre (apres_);

Que fait ``polyfit`` ?
----------------------

``polyfit`` cherche à déterminer un polynome qui "colle" au mieux à la série donnée.

L'utilisation la plus basique est  :

.. sourcecode:: matlab

    tableau_de_coefs = polyfit(abscisses, ordonnnes, degres_du_polynome);

C'est un excellent moyen de faire rapidement une régression linéaire sur une série de mesures !

.. _avant: /static/images/polyfit/avant.png
.. _apres: /static/images/polyfit/apres.png
