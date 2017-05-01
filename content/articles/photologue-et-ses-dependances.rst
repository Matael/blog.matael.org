=============================
Photologue et ses dépendances
=============================

:date: 2015-01-04 11:28:38
:slug: photologue-et-ses-dependances
:authors: matael
:summary: Quand le facultatif devient nécessaire
:tags: Python, django, imported

Django
======

J'ai un fort penchant pour Python_, et quand il s'agit de développement web, plusieurs choix s'ouvrent :

- laisser Python de côté au profit de PHP
- utiliser un micro-framework comme Bottle_
- sortir la grosse Bertha : Django_

Lorsque les sites commencent à prendre un peu d'ampleur, Django devient une excellente base : le développement est rapide et fiable.
De plus, l'utilisation d'un langage comme Python permet d'avoir un code clair et facile à lire (<troll>l'inverse de PHP quoi.... </troll>).
Finalement, je trouve que leur devise leur va bien : 

    The Web framework for perfectionists with deadlines

Photologue
==========

A l'image de Python en général, Django dispose d'excellents modules et, en ce qui concerne la gestion des photos, je me suis largement penché vers Photologue_.

Pour un récent site, j'ai eu besoin de photologue et là, un problème (que je n'avais jamais eu est apparu) : de temps à autres, les pages avec des photos ne se chaargeaient pas correctement et m'affichaient une belle erreur ::

    DatabaseError : la transaction est annulée, les commandes sont
        ignorées jusqu'à la fin du bloc de la transaction

J'ai un peu buté sur le bug : c'était la première fois qu'un truc comme ça foirait...

Un petit tour dans les logs m'a appris ce que je voulais ::

    2012-05-21 18:42:25 CEST ERREUR:  la relation « tagging_tag » n'existe pas au caractère 88
    2012-05-21 18:42:25 CEST INSTRUCTION :  
        SELECT DISTINCT "tagging_tag".id, "tagging_tag".name
        FROM
            "tagging_tag"
            INNER JOIN "tagging_taggeditem"
                ON "tagging_tag".id = "tagging_taggeditem".tag_id
            INNER JOIN "photologue_photo"
                ON "tagging_taggeditem".object_id = "photologue_photo"."id"

        WHERE "tagging_taggeditem".content_type_id = 11

        GROUP BY "tagging_tag".id, "tagging_tag".name

        ORDER BY "tagging_tag".name ASC
    2012-05-21 18:42:26 CEST ERREUR:  la transaction est annulée, les commandes sont ignorées jusqu'à la fin du bloc
    de la transaction


``tagging``
===========

Tiens, revoilà la phrase qui nous embêtait... mais là, deuxième problème : photologue peut travailler seul, en tant que galerie d'images dans une instance Django, et peut aussi utiliser des tags (soit en plain text, soit via le module `django-tagging`_).
En aucun cas ce module n'est obligatoire...

Là par contre, on dirait qu'il fouille dans une table qui aurait été crée par ce module et, ne la trouvant pas, qu'il fait la tête.

Un petit ``sudo pip isntall django-tagging`` m'apprend que ce module est bien installé, dans le doute, je décide de le mettre à jour :

.. sourcecode:: bash

    sudo pip install --upgrade django-tagging

La mise à jour se fait sans soucis, mais le site ne marche pas mieux...

Je me dis que le plus simple, ce serait de créer cette foutue table, sans rien y mettre, mais qu'elle existe.
Ainsi, j'ajoute ``tagging`` à mes ``INSTALLED_APPS`` et je met à jour ma DB :

.. sourcecode:: bash

    python manage.py syncdb
    sudo service apache2 reload # au cas où

Et là ? ben tout va bien.

En fait, photologue essaie d'importer ``tagging`` et, s'il y parvient, se comporte comme si celui ci avait été ajouté au site.
Le moyen le plus propre de faire aurait été de modifier le code de photologue pour qu'il n'utilise les tables de ``tagging`` que si celui ci était dans les ``INSTALLED_APPS`` mais là, fallait que je rush...

Voilà donc un article court qui, s'il avait été écrit avant m'aurait évité de chercher une solution plus longtemps...

Bonne soirée !

.. _Python: http://www.python.org/
.. _Bottle: http://bottlepy.org/docs/dev/
.. _Django: https://www.djangoproject.com/
.. _Photologue: http://code.google.com/p/django-photologue/
.. _django-tagging: http://code.google.com/p/django-tagging
