=====================
Git, PHP et redis 3/3
=====================

:date: 2015-01-04 11:25:43
:slug: git-php-et-redis-33
:authors: matael
:summary: 
:tags: git, redis, php, fac, imported

Nous avons maintenant le script qui va bien pour git et une base redis
cool. Plus qu'a intégrer ça dans notre PHP.

--------
phpredis
--------

Le principal souci ici, est que redis_ n'est pas
supporté de base par PHP.

Heureusement, des développeurs bien sympathiques ont créé de jolies
bibliothèques, phpredis_ par
exemple.

~~~~~~~~~~~~
Installation
~~~~~~~~~~~~

Nous aurons besoin de ``phpize`` pour l'installation nous allons donc
installer le paquet ``php5-dev`` qui contient notamment cet outil :

.. code-block:: bash

    sudo apt-get install php5-dev

Ensuite quelques commandes suffisent :

.. code-block:: bash

    git clone https://github.com/nicolasff/phpredis.git
    cd phpredis
    phpize
    ./configure
    make
    make test

PHPRedis est maintenant compilé, reste à l'installer réellement :

.. code-block:: bash

    sudo make install

Normalement tout va bien !

On active alors le module dans apache :

.. code-block:: bash

    sudo echo "extension=redis.so" > /etc/php5/conf.d/redis.ini
    sudo /etc/init.d/apache2 reload

La première commande crée le fichier de configuration contenant la ligne
adéquate pour l'activation de phpredis. La seconde ne fait que recharger
apache2 pour qu'il prenne tout ça en compte.

Vous pouvez bien sûr supprimer les fichiers téléchargés en début
d'installation :

.. code-block:: bash

    rm -rf phpredis

~~~~~~~~~~~~~~~~~~~
Modification du PHP
~~~~~~~~~~~~~~~~~~~

Le ``README`` de phpredis_
nous l'indique clairement, on se connecte à un serveur redis comme suit
:

.. code-block:: php

    <?php

    $redis = new Redis();
    $redis->connect('127.0.0.1'); // port 6379 implicite

    // ... on fait des trucs ici ...

    $redis->close(); // on oublie pas de dire au revoir

    ?>

Ensuite, des méthodes de la classe ``Redis()`` implémentent les
différentes commandes (``get`` notamment).

Par rapport au PHP de la `première partie`_,
on va garder la même structure de boucles imbriquées. On n'oubliera pas
d'ouvrir la connexion tout au début des boucles (et une seule fois) et
de la fermer à la fin.

Pour ce qui est du traitement en plein milieu (au coeur des deux
boucles), nous allons simplement recréer la clé et récupèrer la donnée
voulue. Ici, nous nous contentons d'une interrogation du serveur pour
récupèrer la fameuse ligne :

.. code-block:: php

    $first_line = $redis->get("exosfac:".$folder_name."/".$filename.".mkd");

Il faut savoir que ``$folder_name`` contient le nom du dossier courant
sans le ``./src/`` devant, et que ``$filename`` contient le nom du
fichier sans le ``.mkd``.

Si nous inluons tout ça dans le fichier PHP, nous arrivons à :

.. code-block:: php

    <?php

    // Quelques Variables
    $title = 'Index';
    $dir = './src/*';

    // Affichage du début de la page 
    echo<<<END
    <!doctype html>
    <html lang="fr">
        <head>
        <title>$title</title>
        <meta charset="utf-8"/>
        <link rel="stylesheet" href="main.css" media="screen"/>
        </head>
        <body>
        <header>
            <p><a href="/">$title</a></p>
        </header>
        <div id="main_content">
            <article>

    END;

    // Récupération et affichage du texte de la page
    $fh = fopen("index.mkd", 'r');
    echo Markdown(fread($fh, filesize("index.mkd")));
    fclose($fh);

    // Connexion à redis
    $redis = new Redis();
    $redis->connect('127.0.0.1');


    // Génération de la liste de ressources
    foreach (glob($dir) as $folder) {
        // trouver le nom du fichier seul
        $folder_name = preg_replace('/^\.\/src\//', '', $folder);

        // titre de la catégorie
        echo "<h3>".preg_replace('/^\.\/src\//', '', $folder_name)."</h3>";

        // le texte de présenttion de la catégorie
        $fh = fopen($folder."/index.mkd", "r");
        if ($fh) {
            echo '<div class="intro_category">'
                .Markdown(fread($fh, filesize($folder."/index.mkd"))).'</div>';
        }
        fclose($fh);

        echo '<ul>'; // début de la liste

        // itération sur les fichiers
        foreach (glob($folder.'/*') as $file) {
            if ($file == $folder.'/index.mkd') {
                continue;
            }
            $filename = preg_replace('/\.mkd$/', '', $file);
            $filename = preg_replace('/^\.\/src\/'.$folder_name.'\//', '', $filename);

            // récup. de la première ligne
            $first_line = $redis->get("exosfac:".$folder_name."/".$filename.".mkd");

            // affichage
            echo '<li><a href="/?n='.$folder_name.'/'.$filename.'">'
                .preg_replace('#_#', ' ',$filename).'</a> - '.$first_line.'</li>';
        }

        echo '</ul>'; // fin de liste
    }
    // fermeture la connexion
    $redis->close();

    // Fin de la page
    echo<<<END
    </article>

    <!-- Commentaires Disqus ici -->

    <div style="clear:both;">&nbsp;</div>
    <footer><p>Powered by mkdizer</p></footer>
    </body>
    </html>
    END;

    // EOF

    ?>

Voilà qui normalement devrait suffir à afficher quelque chose du genre

-  fichier1 - premiere ligne du fichier1
-  fichier2 - premiere ligne du fichier2
-  fichier3 - premiere ligne du fichier3
-  etc...

----------
Conclusion
----------

.. figure:: /images/redis/archi2.png
   :align: right
   :width: 300px
   :alt: Architecture à la fin

Nous avons vu au cours de ces trois articles un moyen de mettre
automatiquement à jour une base de donnée redis après un ``git pull``.

Nous avons aussi réussi à joindre PHP et redis au moyen de l'ajout d'un
module à apache.

Toutes ces actions ont finalement abouti à l'architecture présentée
ci-contre.

Sachez enfin que le site utilisant ce système est accessible à
http://exos.matael.org et que cela a vraiment réduit l'utilisation du
disque et du processeur.

Parfois, il suffit d'un petit script et d'une légère modif du système
existant pour vraiment augmenter les performances !

.. _redis: http://redis.io
.. _phpredis: https://github.com/nicolasff/phpredis
.. _première partie:  /writing/git-php-et-redis-13
