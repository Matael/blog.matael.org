==============================
Dataporn Part #1 : Stats phpBB
==============================

:date: 2015-01-04 11:28:38
:slug: dataporn-part-1-stats-phpbb
:authors: matael
:summary: Faire de jolis graphiques avec phpBB
:tags: perl, datalove, imported

Depuis quelques jours, je vais joujou avec le module ``SVG::TT::Graph`` sous Perl.
Pour faire court, `ce module`_ permet de tracer plein de graphiques cools facilement.

Ici, nous allons nous intéresser à un cas simple : tracer un graphique du nombre de posts par personne sur phpBB_.

.. image:: /static/images/dataporn/phpbb.svg
    :width: 600px
    :align: center

Le but est donc de générer un graphe comme celui ci-contre.

La DB de phpBB
==============

phpBB peut utiliser plusieurs SGDB, l'instance tournant chez moi est sous PostGreSQL_.

Ce qui nous intéresse, c'est :

- le nom d'utilisateur (``username``)
- le nombre de posts (``user_posts``)

Ces deux champs sont dans la table ``<prefixe>users`` où ``<prefixe>`` est le préfixe choisi à l'installation de phpBB.

*Note: pour ceux qui ne se souviennent plus, la conf de phpBB est disponible dans le fichier ``config.php`` de l'installation du forum.*

En Perl, c'est le module ``DBI`` qui gère les connexions aux DBs SQL (ce n'est pas le seul, mais il le fait très bien).
On aura aussi besoin de ``DBD::Pg`` pour spécifier une connexion à PostGreSQL.

L'installation des modules
==========================

Histoire de pas s'embêter, on va passer par `cpanmin.us`_ ::

    curl -L http://cpanmin.us | perl - --sudo SVG::TT::Graph

ou, sans ``curl`` ::

    wget -O - ttp://cpanmin.us | perl - --sudo SVG::TT::Graph

On pourra utiliser le gestionnaires de paquets de la distribution pour ``DBD::Pg`` (``CPAN`` n'ayant pas voulu me l'installer ici) ::

    sudo apt-get install libdbd-pg-perl

pour une distro *Deban-based*.


Ecriture du script
==================


Cueillons les données
---------------------

On va commencer par écrire le début du script où l'on va chercher les données.
La seconde partie consistera à les mettre sous forme de graphe.

Commençons par une série de variables de config pour pouvoir facilement réutiliser le script :

.. code-block:: perl

    #!/usr/bin/env perl

    use strict;
    use warnings;
    use DBI;
    use SVG::TT::Graph::BarHorizontal;

    my $user = "user_for_db";
    my $passwd = "pass_for_this_user";
    my $dbname = "phpbb";
    my $prefix = "phpbb_";

    # pour tout à l'heure
    my $graph_title = "titre du graphe";
    my $graph_subtitle = "sous-titre";


Les noms des variables parlent d'eux mêmes.
Notez que j'inclue systématiquement : ``warnings`` et ``strict`` qui forcent le développeur à coder proprement.

Il nous faut maintenant aller chercher les données, et donc ouvrir une connexion vers la DB :

.. code-block:: perl

    my $dbh = DBI->connect(
        "dbi:Pg:host=localhost;dbname=$dbname", # DSN
        $user, $passwd, {RaiseError => 1}
    );

La chaine ``DSN`` reprend le nom du module de liaison (``dbi``), le SGDB (``Pg``), l'*host* et le nom de la db (``dbname``).

On récupère ensuite une liste d'*users*.
Ici, dans la requête SQL (``$sql``), on filtre un peut en ne prenant que les *users* ayant plus de 10 posts, pour éviter de surcharger le graphe.

.. code-block:: perl

    # get users
    my $sql = "SELECT username,user_posts FROM ".$prefix."users WHERE user_posts>10";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $results = $sth->fetchall_hashref("username");

Ici, le cheminement est classique ::

    connect -> prepare -> execute -> fetch

Notez que la variable ``$prefix`` est *interpolée* dans la chaine de requête SQL.
Cette pratique est déconseillée, mais ici, ``$prefix`` est règlée par l'admin lui même, à moins qu'il soit stupide, il ne devrait pas se faire de mal...

On passe ensuite cette requête à ``$dbh->prepare()`` qui renvoie un *Statement handler* stocké ici dans ``$sth``.
Enfin, on éxécute cette requête avec la méthode ``execute()`` de ``$sth``.

La méthode ``fetchall_hashref`` permet de récupérer les résultats sous forme d'une *hashref*, elle prend en paramètre le nom d'un champ dont la valeur est unique pour chaque champ.

**ATTENTION : Ici, la méthode que je vous présente fonctionne mais n'implémente aucune gestion des erreurs. Ce script peut être considéré safe ici parce que l'on sait ce qu'il y a dans la base. En production, il faudrait faire attention aux retours des méthodes et aux erreurs.**

Le graphe
---------

Avant d'utiliser le beau module cité au début, on aura besoin de générer deux tableaux, un pour les étiquettes (``@fields``) et l'autre pour les données (``@posts``).

Vu notre utilisation de ``fetchall_hashref`` il nous suffit d'utiliser les clés de ``%{$results}`` pour générer le premier.

Pour le deuxième, on parcours le ``@fields`` et pour chaque clé, on ajoute la valeur de ``$results->{clé}->{user_posts}`` tableau ``@posts`` qu'on aura créé avant sans l'initialiser.

.. code-block:: perl

    my @fields = keys %{$results};

    my @posts;
    foreach my $k (@fields) {
        push @posts, $results->{$k}->{user_posts};
    }

*Note: la fonction ``push`` permet d'ajouter à la fin d'un tableau.*

Finalement, on suit `la doc`_ de ``SVG::TT::Graph::BarHorizontal`` pour créer le graphe qui nous convient :

.. code-block:: perl

    my $graph  = SVG::TT::Graph::BarHorizontal->new({
        'height' 				=> '700',
        'width' 				=> '600',
        'fields' 				=> \@fields,
        'graph_title' 			=> $graph_title, # défini au début
        'show_graph_title' 		=> 1,
        'graph_subtitle' 		=> $graph_subtitle, # idem
        'show_graph_subtitle' 	=> 1,
        'scale_integers' 		=> 1
    });

    $graph->add_data({
        'data' 		=> \@posts,
        'title' 	=> 'Posts' # titre pour cette série
    });

On passe bien des **références** sur les tableaux, Perl ne permettant que des scalaire dans les paramètres.

Pour ce qui est de l'instanciation, je ne détaillerais pas : les noms sont déjà assez explicites.

Affichage
=========

On ne s'embetera pas à gèrer l'écriture dans un fichier, le SVG n'étant que du texte, on l'écrira sur la sortie standard, libre à nous de le rediriger ailleurs ensuite (dans un fichier par exemple).

C'est la méthode ``burn()`` qui permet de générer le SVG final, on utilisera ``print`` pour l'afficher :

.. code-block:: perl

    print $graph->burn();


Fin
===

Histoire de bien faire, voici le code complet du script, suivi d'un exemple d'utilisation :

.. code-block:: perl

    #!/usr/bin/env perl

    use strict;
    use warnings;
    use DBI;
    use SVG::TT::Graph::BarHorizontal;

    my $user = "user_for_db";
    my $passwd = "pass_for_this_user";
    my $dbname = "phpbb";
    my $prefix = "phpbb_";
    my $graph_title = "titre du graphe";
    my $graph_subtitle = "sous-titre";

    my $dbh = DBI->connect(
        "dbi:Pg:host=localhost;dbname=$dbname",
        $user, $passwd, {RaiseError => 1}
    );

    # get users
    my $sql = "SELECT username,user_posts FROM ".$prefix."users WHERE user_posts>10";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $results = $sth->fetchall_hashref("username");
    my @fields = keys %{$results};

    my @posts;
    foreach my $k (@fields) {
        push @posts, $results->{$k}->{user_posts};
    }

    my $graph  = SVG::TT::Graph::BarHorizontal->new({
        'height' 				=> '700',
        'width' 				=> '600',
        'fields' 				=> \@fields,
        'graph_title' 			=> $graph_title,
        'show_graph_title' 		=> 1,
        'graph_subtitle' 		=> $graph_subtitle,
        'show_graph_subtitle' 	=> 1,
        'scale_integers' 		=> 1
    });

    $graph->add_data({
        'data' 		=> \@posts,
        'title' 	=> 'Posts'
    });

    print $graph->burn();


On pourra appeller le module et placer le SVG généré dans ``phpbb.svg`` *via* :

.. code-block:: bash

    perl mon_script.pl > phpbb.svg

et vous pourrez sans problème visualiser le svg ainsi créé.


.. _ce module: http://search.cpan.org/~fangly/SVG-TT-Graph-0.21/
.. _PostGreSQL: http:/postgresql.org
.. _cpanmin.us: http://cpanmin.us
.. _phpBB: http://www.phpbb.com
.. _la doc: http://search.cpan.org/~fangly/SVG-TT-Graph-0.19/lib/SVG/TT/Graph/BarHorizontal.pm
