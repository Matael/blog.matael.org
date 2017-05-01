======================================
Choix Techniques pour une TodoList web
======================================

:date: 2015-01-04 11:28:38
:slug: choix-techniques-pour-une-todolist-web
:authors: matael
:summary: Apprentissage au travers d'un exercice classique
:tags: redis, python , bottle, lesscss, imported

Plutot que *crawler* les docs de certains outils en vain, il est parfois mieux de s'y essayer.
C'est ce dont nous allons parler.

J'essaierai d'argumenter mes choix techniques d'expliquer pourquoi ces composants m'ont attiré plus que d'autres.

Objectif
========

Il y a peu, je me suis lancé dans l'écriture d'un application web pour la gestion de TodoList.

Cet exercice est un classique parmi les classiques.
En fait, ce n'était pas mon coup d'essai ; alors pourquoi encore une ?

Ces derniers temps, j'ai découvert plusieurs composants que je souhaitais tester mais dans un environnement *"réel"*.
En fait, l'écriture de cette application était un simple prétexte pour apprendre à utiliser des outils prometteurs, pour les confronter à un environnement plus réaliste que les exemples de leur doc.

Finalement, cette application deviendra peut être le support d'un tutoriel pour Bottle_.

    **Note**

    Une bonne partie de l'application peut certainement être améliorée.
    Je ne cherchais pas à créer quelque chose de parfait mais à prendre en main une série de composants.

Choix Techniques
================

Les composants que j'ai choisis pour construire cette application sont :

- Bottle_
- LessCSS_
- Redis_

Voyons plus en détail ce qui a motivé ces choix.

Bottle
------

Je ne suis pas à mon premier site utilisant Bottle_.
En effet, ce micro-framework web écrit en python_ présente bien des avantages.

Tout d'abord, comme tout micro-framework, il est extrèmement léger.
Je ne cherchais pas ici à créer une impressionnante usine à gaz mais bien quelque chose de soft.
J'avais besoin de rapidité dans le développement et d'agilité.
Finalement, Bottle m'offrait tout ce que je voulais de ce côté.

La seconde raison motive le choix de python_ comme langage plutot qu'autre chose.
Python est extrèmement flexible et puissant.
De plus, les règles syntaxiques de python forcent à produire un code lisible (et par conséquent maintenable).

LessCSS
-------

LessCSS_ est un langage ajoutant une composante dynamique au CSS.

J'avais déjà entendu parlé de cet outil mais ne l'avais jamais testé.
Une des avantages de LessCSS_ est que les feuilles de styles sont compilées vers CSS à la volée sur la machine cliente. 

Je suis relativement mauvais en design et surtout, je trouve la syntaxe CSS particulièrement lourde (les suites de sélecteurs par exemple).
L'imbrication de règles dans d'autres autorisée par LessCSS_ en fait un outil très puissant et agréable.

Notez que si vous craignez que les machines clientes ne disposent pas de javascript (ce qui est de plus en plus rare), vous pouvez compiler les feuilles de style côté serveur.

Redis
-----

C'était pour moi la **grande nouveauté**.

Les deux principaux avantages que je vois a Redis_ sont :

- la correspondance parfaite entre ses structures de données et celles de python_
- sa rapidité légendaire.

Le `Little Redis Book`_ m'a donné envie de tester Redis_ plus en profondeur et j'en ai enfin eu l'occasion

Notons enfin que les interfaces vers Redis sont nombreuses et que maîtriser un tel outil peut devenir vite un atout (par exemple pour faire communiquer des applications très différentes au sein d'un même système via des canaux `pub/sub`_).

Voilà donc pour le choix d'une base NoSQL plutot qu'une DB SQL classique.

Attention, même si Redis_ ressemble parfois à un petit bout de paradis, son contexte d'utilisation est relativement spécifique (ce qui permet cette puissance).
Une DB SQL classique est plus générale, ce qui s'en ressent sur la facilité d'utilisation, mais résout d'autres problèmes.

Redis enfin est très léger pour un DB stockée en RAM ; c'est un bon point ;)

Impressions
===========

Au cours du développement
-------------------------

Il m'a fallu un peu de temps pour prendre en main Redis, suite à quoi le développement est devenu vraiment très fluide.
L'interface Redis/Python se fait très bien et le module fourni est vraiment complet.

Ce qui peut être déroutant, c'est de déterminer la structure de la DB Redis, en effet, fonctionnant en clés/valeurs, cette DB sort des paradigmes biens connus.
On s'y fait toutefois très bien et l'adaptation ne traine pas.

Il faut reconnaitre aussi que les docs fournies par les différents sites sont très complètes et offrent rapidement des réponses.

Du côté de LessCSS_, il faut avouer que c'est un petit paradis.
Je n'avais jamais codé un *"design"* aussi rapidement.
En fait, pour la première fois, CSS m'a semblé fluide et facile à écrire ;)

A l'utilisation
---------------

Bien sûr, maintenant que cette appli est codée, je l'utilise ;)

Je la trouve rapide (aucun lag) et plutot agréable.
Je reverrais bien deux trois trucs, mais pour le moment, j'ai pas le temps.

Toujours est il qu'aucun des composants ne fait défaut et que celle ci ne vient pas surcharger le serveur (pas du tout en fait \\o/).

Conclusion
==========

Voilà donc la fin de ce (court) parcours de mes choix pour l'écriture d'une TodoList Web basique.

Tout le code est disponible ici_ et est placé sous license GNU/GPLv3.
Je pense que pour mieux comprendre la manière dont les composants sont agencés, il sera plus simple de lire le code qui est relativement simple et concis.

Je pense réutiliser plus souvent ce genre d'outils tant ils ont été agréables.
En fait, celui qui m'a le plus bluffé par sa simplicité, c'est LessCSS_ qui va probablement changer ma manière de voir les feuilles de style ;)

.. _Bottle: http://bottlepy.org/
.. _LessCSS: http://lesscss.org/
.. _Redis: http://redis.io
.. _Little Redis Book: http://openmymind.net/2012/1/23/The-Little-Redis-Book/
.. _python: http://python.org/
.. _pub/sub: http://redis.io/topics/pubsub
.. _ici: https://github.com/Matael/pyre-todo
