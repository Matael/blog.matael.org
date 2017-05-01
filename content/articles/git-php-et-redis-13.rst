=================
Science culinaire
=================

:date: 2015-01-04 11:25:42
:slug: git-php-et-redis-13
:authors: matael
:summary: 
:tags: lol, imported

Je suis un mauvais cuisinier, mais parfois, je me pose des questions.

---------
Les faits
---------

Comme un certain nombre de personnes, je cuisine avant tout pour me
nourrir et j'accorde finalement assez peu d'importance à l'action de
cuisiner elle même.

L'autre jour, je me suis mis en tête de tester une recette de gateau au
chocolat (*slurp !*) au micro-ondes (*wtf ?*) proposée par les étudiants
de l'IUT GEA.

Après avoir vaincu ma réticence, j'ai attaqué la recette (disponible
ici_ avec quelques
autres) :

    **Moelleux au chocolat**

    **Préparation** : 5min **Cuisson** : 4min

    *Ingrédients (pour 4 pers.)*

    -  60g de farine
    -  125g de beurre
    -  125g de chocolat
    -  60g de sucre
    -  3 oeufs
    -  1 cuillère à café de levure

    *Préparation*

    Faire fondre le beurre et le chocolat au micro-ondes.

    Mélanger le sucre et les oeufs entiers, ajouter la farine et la
    levure puis le chocolat et le beurre fondus. Mettre le tout dans un
    moule passant au micro-ondes et cuire environ 4min pour une
    puissance de 650W.

Après une brève bataille, le gateau fut près... et bon ! (oui je sais ça
m'a surpris aussi).

Bien, certes il est bon, mais subsistent quelques grumeaux jaunâtres au
beau milieu du chocolat. Un simple état des lieux quand à mes talents de
cuisinier suffit pour comprendre qu'il s'agit d'oeuf mal incorporé.
Qu'importe ! me dis-je, le gateau est bon, c'est une réussite !

Je laisse donc l'incident comme tel et savoure mon premier gateau au
micro-ondes.

------------
La réflexion
------------

Après coup et suite à une discussion avec mon amoureuse (ça fait peut
être cul-cul la praline, mais c'est vraiment mieux que *"ma meuf"* et
puis merde ! qu'est ce que ça peut vous faire !) j'en suis venu à me
demander quel était le composant principal du gateau au chocolat.

La réponse généralement admise (et parfaitement biaisée) est la suivante
: **le chocolat** ! Mais le nom du produit est trompeur !!

Regardons, pour bien faire, le poids de chacun des ingrédients :

    -  60g de farine
    -  125g de beurre
    -  125g de chocolat
    -  60g de sucre
    -  3 oeufs
    -  1 cuillère à café de levure

Pour les 4 premiers, c'est évident, pour le dernier, on peut le
considérer négligeable devant le reste (gosso modo, on doit avoir 3 à 4g
de levure)....

Mais pour les oeufs nous avons une quantité exprimée non pas en poids
mais en nombre d'entités (ici 3).

Wikipedia_ nous dit :

    Au cours du XXe siècle, la masse de l'oeuf est passée à 60 g alors
    qu'elle était de 50 g aux siècles précédents.

On a donc 3 oeufs d'un poids moyen de 60g, ce qui nous fait **180g**
d'oeuf !

On a donc **plus d'oeuf que de chocolat** !

Pour bien s'en rendre compte, voici un petit diagramme :

.. figure:: /images/gateau/diag.png
   :align: center
   :alt: Diagramme

-------------
La conclusion
-------------

Si l'on résume (et que l'on passe tout ça à la moulinette de la `logique
shadok`_ ), un gateau au
chocolat est en fait le hack d'une **omelette** dont les constituants
principaux (lardons, oignons, etc...) auraient étés remplacés par du
chocolat, du beurre et 2-3 trucs presques négligeables !

Sur ce, bon appétit, moi, je retourne dévorer une tranche d'omelette !!

.. _Wikipedia: http://fr.wikipedia.org/wiki/Oeuf_(cuisine)
.. _logique shadok: http://www.youtube.com/watch?v=TMt6TDQe4nQ
.. _ici: http://wiki.matael.org/recettes_etudiantes
