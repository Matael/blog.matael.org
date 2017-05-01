========================
PostGreSQL et l'encodage
========================

:date: 2015-01-04 11:27:47
:slug: postgresql-et-lencodage
:authors: matael
:summary: Faire cohabiter LATIN1 et UTF8
:tags: postgresql, imported

Lorsque j'ai installé ce serveur, je suis allé un peu vite et j'ai pas vraiment fouillé la configuration de chaque composant.

Ajourd'hui, plus d'un an après, je me rends compte que, sur PostGreSQL_ au moins, il aurait fallu faire attention.

Le problème
===========

Lors de l'installation, Postgres c'est automatiquement mis en LATIN1 pour l'encodage.

Rien de bien grave me direz vous sauf que certains symboles ne sont pas reconnus (le symbole de l'euro par exemple).

Lors du déploiement d'un site professionnel sur ce serveur, j'ai eu besoin d'une base de donnée encodée en utf8, et là, problème.

Ayant purement et simplement horreur du SQL (et n'y connaissant que le minimum syndical), j'ai essayé un truc comme ça :

.. sourcecode:: sql

    CREATE DATABASE MaBase ENCODING 'UTF8';

J'y ai cru au début, pas longtemps, mais un peu.

La réponse ne se fit pas attendre::

    Erreur SQL :

    ERREUR:  l'encodage UTF8 ne correspond pas à la locale fr_FR
    DETAIL:  Le paramètre LC_CTYPE choisi nécessite l'encodage LATIN1.

    Dans l'instruction :
    CREATE DATABASE MaBase ENCODING 'UTF8';

Pas cool...

La solution
===========

Vu que je suis trop bête pour lire le manuel **avant** d'installer, je dois maintenant trouver une solution.

En cumulant plusieurs posts de plusieurs forums et le manuel de ``createdb``, j'arrive à ça :

.. sourcecode:: bash

    createdb -U mon_user -l fr_FR.UTF8 -E UTF8 MaBase

L'option ``-U`` permet de spécifier l'utilisateur avec lequel lancer la requête, ``-l`` permet de définir la langue et ``-E`` l'encodage.

Je me disais, *chic ! le problème est réglé !* et là::

    createdb : la création de la base de données a échoué :
    ERREUR:  le nouvel encodage (UTF8 est incompatible avec
    l'encodage de la base de données modèle (LATIN1)
    ASTUCE : Utilisez le même encodage que celui de la base
    de données modèle, ou utilisez template0 comme modèle.

Ben en voilà un truc sympa : il me donne la solution, un coup de ``man`` plus tard, je découvre l'option ``-T`` permettant de spécifier un modèle de DB.

Je retente donc avec ce nouveau paramètre :

.. sourcecode:: bash

  createdb -U mon_user -l fr_FR.UTF8 -E UTF8 MaBase -T template0

Et là, **youpi** ! Tout marche.

Ce n'était peut être rien, mais ce truc m'aura gonflé un moment.
Désormais, le site est en ligne et tout va bien !

Mais...
=======

Il faut quand même savoir une chose, c'est que ce truc ne marche (à ma connaissance) qu'avec les versions >8.4 de PostGreSQL_.
La possibilité de créer des bases d'encodages différent *à l'arrache* avait été supprimé car cela générait des conflits.

On peut de nouveau le faire, et c'est tant mieux.

Notez toutefois que si vous faites une installation toute neuve de Postgres et que vous utilisez ``initdb``, vous aurez alors le moyen de choisir *locale* et encodage, vous épargnant ainsi une jolie prise de tête.

Bonne chance pour la suite, et à bientot !


.. _PostGreSQL: http://www.postgresql.org/
