=============================
Faire des graphes sur twitter
=============================

:date: 2015-01-04 11:28:40
:slug: faire-des-graphes-sur-twitter
:authors: matael
:summary: Mais qui utilise le plus ce hashtag ?
:tags: python, twitter, matplotlib, imported

Après un évènement organisé à la CCI au Mans (un Jelly lors de la WorldWide Jelly Week), je me suis dit que ça pouvait
être intéressant de savoir qui avait le plus utilisé le *hashtag* proposé par les organisateurs : `#jellyLeMans`_.

On y était présent avec le HAUM, le jeune hackerspace manceau, mais comme vous allez le voir, on est pas vraiment dans
le TOP 10 des utilisateurs du *hashtag*.

L'objectif
==========

On cherche à générer un graphe (genre *pie chart*) des gens qui ont tweeté avec le hashtag **#JellyLeMans**.
Vu qu'un certains nombre de personnes l'ont utilisé, on se contentera de prendre en compte ceux ayant tweeté un plus
grand nombre de fois que la moyenne.

Twitter Time
============

L'API de recherche pour twitter est assez simple : pas besoin de *token* ou que sais-je, de simples requêtes HTTP
suffisent. Il faut savoir que l'API a quelques limitations,... on ne s'en préocupera pas ici, mais si vous vous posez
des questions regardez sur la page `Using The Twitter Search API`_.

La beauté de python tient probablement dans le nombre et la qualité de ses modules (en plus d'un langage facilement
lisible). On trouvera sans soucis le module twitter_ qui nous permet d'utiliser l'API Twitter sans s'inquiéter des
détails techniques.

Celui ci est téléchargeable sur pypi (ou via *pip* ou *easy_install*) mais aussi directement dans les paquets de
certaines distros.

A noter que le script que je propose est fait pour Python 3. Il semblerait toutefois que celui fonctionne aussi sur
Python 2.7 (pas testé toutefois...).

La récupération de tweets correspondant à une recherche est simple avec ce module :


.. code-block:: python

    from twitter import Twitter

    # on instancie la connexion à l'API de recherche
    twlk = Twitter(domain="search.twitter.com")

    hashtag = "#jellylemans"

    # res contient une structure (dico en fait)
    # avec une série d'infos sur la requête
    res = twlk.search(q=hashtag)


L'inconvénient, c'est qu'on est ainsi limités une vingtaine de tweets...

On peut ruser en utilisant une des clés du dico de retour : `next_page`` qui n'existe que si une autre page existe (la
recherche ainsi que le reste des API permettant la récupération de beaucoup de tweets est paginée).

On utilise alors une boucle pour en récupérer le maximum :

.. code-block:: python

    # On cherche à récupérer les noms d'users et leur nombre de tweet
    users_count = {}
    users = []

    try:
        # genere une KeyError au besoin (si dernière page)
        while res['next_page']:

            # pour chaque tweet renvoyé
            for i in res['results']:

                # si on a pas encore eu de tweet de cet @user,
                # on l'ajoute à la liste et au dico
                if i['from_user'] not in users:
                    users.append(i['from_user'])
                    users_count[i['from_user']] = 0

                # on incrément le compteur (dans le dico)
                users_count[i['from_user']] += 1

            # on passe res à la page suivante
            res = twlk.search(q=hashtag, page=res['page']+1)

    # s'il s'agit de la dernière page
    except KeyError:
        pass # on abandonne sans rien dire

La première question pourrait être : mais pourquoi faire une liste **et** un dico pour faire nos comptes ?

Intuitivement, je me suis dit que faire :

.. code-block:: python

    if item in liste:
        #...

serait plus rapide que :

.. code-block:: python

    if item in dico.keys():
        #...

Après vérification (regarder la fonction magique ``%%timeit`` sur IPython, c'est assez simple), j'ai noté qu'il y avait
effectivement une petite différence (pas énorme mais j'avais une liste et un dico de quelques dixaines d'éelements/de
couples) donc rien de vraiment représentatif).


Reste à ne conserver que les utilisateurs ayant tweeté plus que la moyennne :

.. code-block:: python

    # on récupère le nombre d'users
    count = len(users_count)
    # on calcule la moyenne
    moy = sum(users_count.values())/count

    # dans une v1, ça permettait de choisir ou placer la barre :
    #   - 1.0 : on garde au dessus de la moyenne
    #   - 2.0 : on garde au dessus de deux fois la moyenne, etc...
    ratio = 1.0

    # on fait une liste pour les résultats et une pour les users
    # pour le graphe, il faudra que ce soit séparé
    final_count = []
    users = [] # on réutilise la variable

    for i in users_count.keys():    # peut importe le temps que ça prend,
                                    # c'est calculé qu'une fois
        if users_count[i] >= moy*ratio:
            # on ajoute ceux dépassant ratio*moy à la liste users et leur
            # nombre de tweet à final_count
            final_count.append(users_count[i])
            users.append(i)

En utilisant les Dict Comprehension, il y aurait surement eu moyen de réduire ça a une seule ligne, mais tant pis ;).

Graphe !
========

Pour la génération du graphe, on utilisera la MatPlotLib_. Si vous n'avez pas déjà installé ce module hyper pratique
pour la visualisation de données en 2D/3D, je vous conseille de le faire au plus vite !

Pour Arch, cette commande devrait suffir :::

    $ sudo pacman -S python-matplotlib


Pour Debian/Ubuntu, il me semble que le paquet est installable via :::

    $ sudo apt-get install python3-matplotlib

Une fois que c'est fait, il ne reste qu'a l'utiliser.

Un outil pour faire des *pie charts* est déjà présent dans la lib :

.. code-block:: python

    from matplotlib import pyplot

    # on ajoute un pie chart à l'espace de pyplot
    pyplot.pie(
        final_count,            # param1 : les données à afficher
        labels=users,           # les labels (ici les noms d'utilisateurs)
        colors=('b','g', 'r'),  # les couleurs a utiliser (je sais c'est pas beau)
        labeldistance=1.05      # distance graphe/label
    )

    # le title à utiliser
    pyplot.title("Qui a le plus tweete {} ?".format(hashtag))

    # et on enregsitre (l'extension .png est ajoutées automatiquement)
    pyplot.savefig("pie1")

Juste à noter que pour ``labeldistance``, une distance de 1 signifie que labels et graphe se touchent.

Combo script complet
====================

Juste pour avoir le script complet au moins une fois :

.. code-block:: python

    # -*- coding:utf8 -*-
    from twitter import Twitter
    from matplotlib import pyplot

    # on instancie la connexion à l'API de recherche
    twlk = Twitter(domain="search.twitter.com")

    hashtag = "#jellylemans"

    # res contient une structure (dico en fait)
    # avec une série d'infos sur la requête
    res = twlk.search(q=hashtag)

    # On cherche à récupérer les noms d'users et leur nombre de tweet
    users_count = {}
    users = []

    try:
        # genere une KeyError au besoin (si dernière page)
        while res['next_page']:

            # pour chaque tweet renvoyé
            for i in res['results']:

                # si on a pas encore eu de tweet de cet @user,
                # on l'ajoute à la liste et au dico
                if i['from_user'] not in users:
                    users.append(i['from_user'])
                    users_count[i['from_user']] = 0

                # on incrément le compteur (dans le dico)
                users_count[i['from_user']] += 1

            # on passe res à la page suivante
            res = twlk.search(q=hashtag, page=res['page']+1)

    # s'il s'agit de la dernière page
    except KeyError:
        pass # on abandonne sans rien dire


    # on récupère le nombre d'users
    count = len(users_count)
    # on calcule la moyenne
    moy = sum(users_count.values())/count

    # dans une v1, ça permettait de choisir ou placer la barre :
    #   - 1.0 : on garde au dessus de la moyenne
    #   - 2.0 : on garde au dessus de deux fois la moyenne, etc...
    ratio = 1.0

    # on fait une liste pour les résultats et une pour les users
    # pour le graphe, il faudra que ce soit séparé
    final_count = []
    users = [] # on réutilise la variable

    for i in users_count.keys():    # peut importe le temps que ça prend,
                                    # c'est calculé qu'une fois
        if users_count[i] >= moy*ratio:
            # on ajoute ceux dépassant ratio*moy à la liste users et leur
            # nombre de tweet à final_count
            final_count.append(users_count[i])
            users.append(i)



    # on ajoute un pie chart à l'espace de pyplot
    pyplot.pie(
        final_count,            # param1 : les données à afficher
        labels=users,           # les labels (ici les noms d'utilisateurs)
        colors=('b','g', 'r'),  # les couleurs a utiliser (je sais c'est pas beau)
        labeldistance=1.05      # distance graphe/label
    )

    # le title à utiliser
    pyplot.title("Qui a le plus tweete {} ?".format(hashtag))

    # et on enregsitre (l'extension .png est ajoutées automatiquement)
    pyplot.savefig("pie1")

Vous pouvez aussi le *forker* directement depuis Gist : `#jellylemans @ Gist`_

Pour le résultat final, ça donne ça :

.. image:: /static/images/twitter_graphe/graphe.png
    :align: center

.. _#JellyLeMans: https://twitter.com/search?q=%23jellylemans&src=typd
.. _Using The Twitter Search API: https://dev.twitter.com/docs/using-search
.. _twitter: http://pypi.python.org/pypi/twitter/
.. _MatPlotLib: http://matplotlib.org/
.. _#jellylemans @ Gist: https://gist.github.com/4537364
