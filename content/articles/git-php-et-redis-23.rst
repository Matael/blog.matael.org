=====================
Git, PHP et redis 2/3
=====================

:date: 2015-01-04 11:25:43
:slug: git-php-et-redis-23
:authors: matael
:summary: 
:tags: git, redis, php, fac, imported

Après avoir planté correctement le décor, passons à la pratique : faire
collaborer redis et git.

------------
Redis et Git
------------

git_ est un gestionnaire de versions distribué
que l'on ne présente plus. Extrèmement puissant, il est utilisé pour de
nombreux projet et aussi pour le backend de ce blog et du site présenté
en `première partie`_.

redis_ est un système de stockage clé-valeur NoSQL
puissant et souple. De nombreuses interfaces existent notamment une en
ligne de commande ``redis-cli`` et de nombreuses bibliothèques PHP (dont
phpredis_.

    **Note:**

    Mon serveur tourne sous Debian 6.0, cet article sera donc présenté
    du point de vue d'une distro Debian.

    Les instructions ne devraient pas être difficiles à reproduire
    ailleurs.

-----
Redis
-----

Présentons (très) succintement l'installation et quelques commandes .

~~~~~~~~~~~~
Installation
~~~~~~~~~~~~

Par le plus grand des hasards, la méthode classique marche :

.. code-block:: bash

    sudo apt-get install redis-server

La documentation est dans le paquet ``redis-doc``.

Le gros désavantage de cette méthode est de ne fournir que la version
1.2.6 alors que redis est passé dernièrement en 2.4.5...

Bien que cette version suffise pour ce que nous allons faire, c'est un
peu dommage. Restent plusieurs moyens pour l'*upgrade* :

-  passer par les **backports** (version 2.4.2)
-  récupèrer le .deb depuis wheezy ou sid
-  compiler les sources

La dernière méthode est simplissime :

.. code-block:: bash

    wget http://redis.googlecode.com/files/redis-2.4.5.tar.gz
    tar zxvf redis-2.4.5.tar.gz
    cd redis-2.4.5
    make
    make test

Puis, si les tests ont réussi :

.. code-block:: bash

    make install

Dans le cas de l'installation depuis les paquets, le serveur redis est
lancé automatiquement.

Via les sources, il faudra le lancer avec

.. code-block:: bash

    redis-server

Vous pourrez alors vérifier la version comme suit :

.. code-block:: bash

    $ redis-cli INFO | grep version
    redis_version:2.4.5

~~~~~~~~~~~~~~~~~~
La base de la base
~~~~~~~~~~~~~~~~~~

Redis stocke des couples clé-valeur. Les clés sont des *strings*, les
valeurs peuvent être n'importe quelle structure de données (string,
nombre, liste, tableau, hash, etc...). Notez que toutes les structures
ne sont pas forcément gérées par toutes les modules des langages.

Vous pouvez démarrer un client vers le serveur avec

.. code-block:: bash

    redis-cli

Sachant que le serveur écoute sur le port 6379 par défaut, vous pouvez
aussi utiliser ``telnet`` :

.. code-block:: bash

    telnet localhost 6379

~~~~~~~~~~~~~~~~~
Ajouter un couple
~~~~~~~~~~~~~~~~~

Nous avons déjà vu une commande ``INFO`` qui renvoie des infos sur le
serveur.

On a aussi accès à ``SET`` et ``GET`` :

.. code-block:: bash

    $ redis-cli
    redis> SET foo "bar"
    OK
    redis> GET foo
    "bar"

Ce seront les seules commandes dont nous nous servirons ici, mais sachez
que d'autres existent, ``KEYS`` par exemple récupère la liste des clés :

.. code-block:: bash

    redis> KEYS *
    1) "foo"

----------------
git et les hooks
----------------

Comme j'utilise git_ pour gèrer les versions, il
serait sympa de pouvoir ajouter les nouvelles clés à
redis_ à chaque ``git pull``.

Je ne vais pas me lancer ici dans une intro à git : plein d'articles et
de sites en parlent très bien et vous pourrez toujours jeter un oeil à
`ce livre`_ pour une excellent base.

Sachez que git possède un très puissant système de *hooks*. Vous pouvez
ainsi appeller un script juste avant chaque commit, push, ou comme ici :
chaque pull (et à plein d'autre moments).

Ces scripts sont à placer dans le dépot même, précisément dans le
répertoire ``./.git/hooks/``.

Le nom détermine le moment d'appel, ainsi celui qui nous intéresse ici
est le *hook* nommé ``post-merge``.

Pour le reste, c'est simplement du bash ;)

~~~~~~~~~~~~~~~~~~
Principe du script
~~~~~~~~~~~~~~~~~~

On doit parcourir chacun des dossiers dans ``./src/``, puis chacun des
fichiers dans ces dossiers (ça sent la double ``for``).

Ensuite, il ne faut garder que la première ligne de chaque fichier
(``head`` fait ça très bien) et l'ajouter à redis si elle commence par
un ``#`` (un titre en
Markdown_) tout en
virant ce dièse (on se moque des espaces, HTML ne les prend pas en
compte).

~~~~~~~~~
Le script
~~~~~~~~~

.. code-block:: bash

    #!/bin/bash

    for folder in `ls src`
    do
        for file in `ls src/$folder`
        do
            file_uniq_name="$folder/$file"
            echo "+-> Adding line for key : $file_uniq_name"
            line=`head -n 1 src/$folder/$file | grep ^# | cut -d '#' -f 2`
            redis-cli SET exosfac:$file_uniq_name "$line"
        done
    done

Dans la seconde boucle :

#. La première ligne stocke dans ``$file_uniq_name`` une chaine du genre ``"dossier/fichier"`` dont on est sûr qu'elle soit unique
#. La seconde ligne est juste là pour faire un joli affichage
#. La troisième ligne stocke dasn ``$line`` la première ligne du fichier si elle commence par un dièse et après l'avoir supprimé (le dièse)
#. La dernière ligne stocke dans redis la ligne ``$line`` sous la forme ``exosfac:dossier/fichier``.

Le ``exosfac:`` devant permet de créer des sortes de sous-ensembles de
clés tacites.

De plus, vu notre PHP de base (voir `première partie`_) permettra facilement de
reconstruire cette clé.

Voilà, il ne nous reste plus qu'a écrire un peu de PHP et nous aurons la
première ligne de chaque fichier à côté de son nom sans pour autant
massacrer le disque ;).

.. _git: http://git-scm.org
.. _première partie:  /writing/git-php-et-redis-13
.. _redis: http://redis.io
.. _phpredis: https://github.com/nicolasff/phpredis
.. _ce livre: http://progit.org/book.html
.. _Markdown: http://daringfireball.net/projects/markdown/
