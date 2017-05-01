====================
Octave et diagrammes
====================

:date: 2015-01-04 11:27:47
:slug: octave-et-diagrammes
:authors: matael
:summary: Bode, Nyquist et leurs amis
:tags: octave, matlab, imported

Dans le cadre de mes études, je suis amené à utiliser MatLab_/Octave_. 
Alors qu'une vaste majorité de nos professeurs semblent utiliser Matlab, nous avons plus tendance à nous orienter vers GNU Octave.

En effet, celui-ci est libre et est largement suffisant pour ce que je veux en faire.

L'autre jour, j'ai cherché à tracer des diagrammes de Bode_ sur Octave.
En triturant et en jouant avec ``subplot``, j'ai réussi à obtenir un semblant de diagramme, mais je me suis demandé s'il n'y avait pas plus simple.

Ces diagrammes sont facilement traçables sous Matlab *via* une *Toolbox* payante (pour ce que j'en sais).
Cette *toolbox* propose aussi :

- modélisation de fonction de transfert (via ``tf()``)
- tracé de diagrammes de :
  
  - Bode (``bode()``)
  - Nyquist (``nyquist()``)
  - Black-Nichols (``black()``)

- etc...

En cherchant un peu, j'ai découvert l'existence du paquet ``octave-control`` qui permet d'accèder à des fonctions semblables (entre autres), et ce dans Octave_.

Installation
============

Pour ceux disposant d'une distribution *Debian-based*, le paquet est installable via :

.. code-block:: bash

    sudo apt-get install octave-control

Pour certaines autres distros, le paquet est probablement disponible dans les dépots.
Pour ArchLinux par exemple, le paquet est disponible dans AUR_ sous le nom ``octave-control`` (ô surprise !).

Pour ce qui est des systèmes propriétaires (<troll>sapucépalibre</troll>), je vous laisse le soin de regarder la doc. 

Utilisation
===========

Modélisation de fonctions de transfert
--------------------------------------

Par chance, Octave modélise très bien les fonctions de transfert via ``tf()`` du paquet ``octave-control``. 

On doit préciser à cette fonction au moins deux paramètres : des vecteurs de coefficients.
Finalement, on devra noter ``tf(NUM, DEN)`` où ``NUM`` est le vecteur de coefficient pour le numérateur et ``DEN`` celui pour le dénominateur.

La puissance maximale sur chacun des deux ensemble de termes est déterminé par la longueur des vecteurs. 

Enfin, les coefficients entrés s'appliquent aux termes de puissance décroissante.

Pour l'exemple, essayons de modéliser une équation de la forme :

.. image:: /static/images/octave/formule_cible.png
    :align: center

On identifie nos 2 vecteurs :

- ``NUM = [1]``
- ``DEN = [0.1j, 0.6j, 1]``

Nous pouvons alors modéliser la fonction de transfert via :

.. code-block:: matlab

    clear all;
    close all;

    N = [1];
    D = [0.1j, 0.6j, 1];

    fonction = tf(N,D);

Vous noterez que la variable imaginaire *j* est directement positionnée dans le vecteur.
En effet, celle ci est constante et n'est pas prise en compte directement par ``tf()``.

Enfin, il faut savoir que d'autre paramètres existent et permettent d'être plus précis pour, par exemple, travailler sur un signal réelle et lui appliquer ladite fonction.

Tracé
-----

Tout l'avantage de passer par la modélisation d'une fonction de transfert réside dans le tracé de graphes.

En effet, ``octave-control`` permet d'utiliser plusieurs fonctions de tracé, celle ci utilisant une fonction de transfert en paramètre (pour la modélisation du système).

Reste à tester le tracé de diagrammes avec :

.. code-block:: matlab

    bode(fonction)      # Bode
    nyquist(fonction)   # Nyquist
    nichols(fonction)   # Black-Nichols

Octave vous tracera ainsi de jolis diagrammes *kivonbien*, exemple :

.. image:: /static/images/octave/bode.png
    :align: center
    :width: 600px

Cette possiblité est très sympa quand on doit tester la modélisation de systèmes avec plusieurs vecteurs de coefs.

Conclusion
==========

Après avoir testé la génération de diagrammes (de Bode notament) avec ``subplot`` et ses amis, le paquet ``octave-control`` est un pur bonheur.

En jettant un oeil dans la doc, vous trouverez d'autres fonctions utiles.
Toujours est il que ces simples fonctions ``tf()`` et ``bode()`` permettent d'accélerer grandement la modélisation de systèmes sans pour autant requérir un apprentissage long.


.. _Matlab: http://www.mathworks.fr/
.. _Octave: http://www.gnu.org/software/octave/
.. _Bode: http://fr.wikipedia.org/wiki/Diagramme_de_Bode
.. _AUR: http://aur.archlinux.org
