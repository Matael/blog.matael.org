========================
impress.js et Hovercraft
========================

:date: 2015-01-04 11:28:41
:slug: impressjs-et-hovercraft
:authors: matael
:summary: Comment créer des slides en ReST
:tags: rst, haum, imported

Faire des slides n'amuse personne... et moi le premier. Je *déteste* écrire des diapos et pire encore faire en sorte que
ça ait l'air joli.

Il y a quelques temps, Vincent_ m'a parlé d'impress.js_. Cet outil permet en effet de réaliser une présentation en
HTML5/CSS3/JS en incluant des effets plutot sympas. Vous trouverez sur son blog `un article à propos d'impress.js`_.

Voilà qui semble prometteur mais un problème subsiste : la présentation doit être écrite en HMTL... certes, on aime pas
faire des slides, mais taper du HTML n'a rien de particulièrement excitant...

Après une courte recherche, j'ai déniché Hovercraft_. Cet outil écrit en python présente un intéret majeur : il vous
permet d'écrire vos slides en ReST_ puis de les transformer en une page impress.js.

Voyons comment ça tourne sous le capot.

Installation
============

Rien de plus simple :

.. code-block:: bash

    sudo apt-get install libxml2-dev libxslt1-dev
    sudo pip install hovercraft

Basics
======

Rien de bien compliqué : vous commencez par donner un titre, déterminer la durée des transistions (en millisecondes) et éventuellement un
CSS *via* quelques directives :

.. code-block:: rst

    :title: Votre titre
    :data-transition-duration: 1500
    :css: presentation.css

Ensuite, vous passez aux slides en eux mêmes :

- les transitions sont indiqués par 4 tirets seuls sur une ligne (avec une ligne blanche avant et après);
- suivent les éventuelles directives de position pour le slide;
- enfin, le texte du slide lui même.

Par exemple :

.. code-block:: rst

    ----

    :data-x: 500
    :data-y: 42

    Premier Slide
    =============

    Et mon texte ici

    ----

    :data-rotate-z: r90

    Second slide
    ============

    Et la suite du texte

La présentation ne doit pas finir sur une transition

Directives de position
----------------------

Les directives sont décrites dans la doc_.

Il existe notament les suivantes pour positioner le slide :::

    :data-x:
    :data-y:
    :data-z:

Ainsi que celles ci qui permettent de faire tourner la vue autour d'un axe (en degrés) :::

    :data-rotate-x:
    :data-rotate-y:
    :data-rotate-z:

Et ``:data-scale:`` qui permet les effets de zoom.

On peut les utiliser suivies d'un nombre. Les coordonnées spécifiées sont absolue, sauf si le nombre (positif ou
négatif) est précédé d'un ``r``.

Directives ReST
---------------

D'après ce que j'ai vu, toutes les directives ReST sont reconnues y compris :::

    .. code-block:: lang

        sourcecode

Pour le code source coloré (*via* pygments_).

Compilation
-----------

Pour compiler :

.. code-block:: bash

    $ hovercraft fichier.rst repertoire_cible/

Si le répertoire n'existe pas, il sera créé. Vous y trouverez divers dossiers et fichiers externes ainsi qu'un
``index.html``. Ouvrez le pour accéder à la présentation elle-même.

Style
=====

Il peut être intéressant de rajouter un peu de CSS à la présentation pour passer du morne N&B par défaut à quelque chose
de plus agréable.

La directive ``:css:`` à placer au début permet cela, ainsi que le *flag* ``-c CSSFILE`` ou ``--css CSSFILE``
d'Hovercraft.

Par exemple, un fichier comme celui ci permet un style plus sombre et doux que le style de base :

.. code-block:: css

    @font-face {
        font-family: "Armata";
        src: url(../fonts/Armata-Regular.ttf) format("truetype");
    }

    @font-face {
        font-family: "Bitter";
        src: url(../fonts/Bitter-Regular.ttf) format("truetype");
    }

    @font-face {
        font-family: "BitterItalic";
        src: url(../fonts/Bitter-Italic.ttf) format("truetype");
    }

    @font-face {
        font-family: "BitterBold";
        src: url(../fonts/Bitter-Bold.ttf) format("truetype");
    }

    body {
        background: #14282C;
        color: #60959F;
        font-family: "Armata";
        font-size: 1.5em;
    }

    h1 {
        font-family: "BitterBold";
        text-italic: none;
        font-size: 2em;
    }

    h2 {
        font-family: "Bitter";
    }

    blockquote {
        font-family: "BitterItalic";
    }

    a, em {
        color: #91C5CF;
        text-decoration: none;
        font-weight: bold;
    }

Il faut savoir que d'autres feuilles de style sont aussi inclues (notament pour la console de présentation, nous y
reviendrons).

Style sur un slide particulier
------------------------------

Pour disposer d'un id spécifique à un slide, il suffit d'ajouter en début de slide (juste après la transition
précédente) la directive suivante :

.. code-block:: rst

    :id: id_voulu

L'id sera ajouté à la compilation et vous pourrez l'utiliser dans le CSS.

Fichier externes
----------------

Il est possible de lier des fichiers externes (css, images ou autres) par diverses directives :

.. code-block:: rst

    :css: path/to/css

    .. ou

    .. image:: path/to/image.jpg


Si les chemins vers ces fichiers sont **relatifs** alors il seront copiés dans la ``TARGET_DIR`` à la compilation, le
chemin spécifié sera conservé dans le ``index.html`` généré.

Notes
-----

Il est possible d'ajouter des notes de présentation qui seront affichées dans la console (on y revient).

Ces notes sont ajoutées via :

.. code-block:: rst

    .. note::

        Texte de la note
        sur
        plusieurs lignes
        au besoin :)

Extras
======

Quelques trucs en plus qu'il peut être bon de connaitre.

Templates
---------

Hovercraft accède l'argument ``-t`` ou ``--template`` qui attend un fichier .cfg qui servira de template de
configuration. Un exemple pour ce fichier (tiré de la documentation) :

.. code-block:: ini

    [hovercraft]
    template = template.xsl

    css = css/screen.css
          css/impressConsole.css

    css-print = css/print.css

    js-header = js/dateinput.js

    js-body = js/impress.js
              js/impressConsole.js
              js/hovercraft.js

    resource = images/back.png
               images/forward.png
               images/up.png
               images/down.png

Ce fichier permet notament de chaner le .xls qui contrôle la mise en page.
De ce côté, le plus simple reste la modification du fichier par défaut : ``hovercraft/templates/default/template.xsl``.

Plus d'infos ici_.

Console de présentation
-----------------------

Hovercraft inclus à la présentation finale une console (impressConsole.js_) qui permet de contrôler la présentation.
Celle-ci comprend :

- le slide en cours,
- le slide suivant,
- une horloge,
- un timer (remis à zéro en cliquant dessus),
- des liens pour le changement de slide en avant ou en arrière (les flèches et la barre espace marchent aussi),
- les notes concernant le slide en cours.

J'essaierais de modifier un peu cette console pour qu'elle soit plus agréable qu'elle ne l'est actuellement.

Options en lignes de commange
-----------------------------

Voilà pour finir 3 options qui peuvent s'avérer utiles :

- ``-a`` ou ``--auto-console`` force l'affichage de la console dès le début (utile pour répèter),
- ``-s`` ou ``--skip-help`` désactive l'affichage de l'aide,
- ``-n`` ou ``--skip-notes`` désactive l'inclusion des notes de présentation


Conclusion
==========

Hovercraft et impress.js forment un tandem prometteur et efficace quand on veut créer des diaporamas sans s'encombrer
d'une GUI ni manger du LaTeX.

Il est à noter que toutes les possibilitées d'impress.js ne sont pas transcrites dans Hovercraft (la doc d'impress.js
est dans le code source de la page de présentation, ce qui la rend pas sympa à lire...).

Certaines choses sont probablement à améliorer mais c'est déjà un excellent début.

**EDIT :** il existe aussi slid.es_. Merci à `@fblain`_ pour l'info


.. _Vincent: http://vincent.jousse.org
.. _impress.js: https://github.com/bartaz/impress.js
.. _Hovercraft: http://hovercraft.readthedocs.org/en/1.0/
.. _ReST: http://docutils.sourceforge.net/rst.html
.. _doc: http://hovercraft.readthedocs.org/en/1.0/presentations.html#impress-js-fields
.. _ici: http://hovercraft.readthedocs.org/en/1.0/templates.html#the-template-file
.. _pygments: http://pygments.org
.. _impressConsole.js: https://github.com/regebro/impress-console
.. _slid.es: http://slid.es/
.. _@fblain: https://twitter.com/fblain
.. _un article à propos d'impress.js: http://vincent.jousse.org/comment-creer-une-presentation-orale-qui-en-jette-a-tous-les-coups-avec-exemple/
