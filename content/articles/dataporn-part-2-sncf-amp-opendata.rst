======================================
Dataporn Part #2 : Sncf &amp; OpenData
======================================

:date: 2015-01-04 11:28:39
:slug: dataporn-part-2-sncf-amp-opendata
:authors: matael
:summary: Stats sur les TGV
:tags: python, datalove, imported

Après un `post de Denis Bodor`_ sur `SNCF Appli Lab`_, la SNCF a commencé à envisager sérieusement l'ouverture d'une partie de ses données.
Aujourd'hui, plus d'un an après ce post, un site existe et propose d'ouvrir le débat autour de l'OpenData : `data.sncf.com`_.
On y trouvera notamment un lien vers un site (apparement en test) proposant les `premiers jeux de données ouverts`_.

Nos données
===========

Dans cet article, nous nous intéresserons aux données d'avril 2012 sur la ponctualité des TGV (`disponible ici`_).
Il s'agit d'un fichier CSV_ contenant 4 colonnes :

- Départ
- Arrivée
- Nb de circulations
- Nb trains en retard à l'arrivée

Ensuite, suivent 114 lignes de données.

Processing
==========

Avant toute chose, il vous faudra deux modules python pour aller au bout de cet
article.

Le premier est le module ``csv`` normalement inclus par défaut dans la
distribution standard de python.
Ce module permettra de lire le fichier CSV plus facilement que si nous avions dû
réécrire un parser à la main ;)

Le second module permet lui de tracer des graphes.
Il s'agit en fait du pendant python du module ``SVG::TT::Graph`` que nous avions
utilisé en perl dans `cet article`_, en python, il s'appelle ``svg.charts``.

Finalement, les deux seules choses à savoir c'est que ce module
(disponibles dans plusieurs langages) est porté depuis Ruby et qu'en python, on
peut l'installer comme ça :

.. code-block:: bash

    sudo pip install svg.charts

Notez enfin que, tournant sur ArchLinux, j'ai rédigé ce script pour **python3**.

Pré-traitement
--------------

Doublons
~~~~~~~~

Nous allons essayer de créer un graphe recensant le pourcentage de trains à l'heure et de trains en retard pour chaque trajet.

En observant les données, on remarque que l'aller et le retour d'un même trajet sont recensés dans 2 lignes différentes ainsi, il nous faudra regrouper les enregistrements aller et retour.

Par exemple, on passera de ::

    PARIS MONTPARNASSE;ANGOULEME;318;28
    ANGOULEME;PARIS MONTPARNASSE;348;53

à ::

    PARIS MONTPARNASSE;ANGOULEME;666;81

Ça, on le fera au dernier moment, dans le script lui même.

Noms de champs
~~~~~~~~~~~~~~

Si on regarde la première ligne du fichier de données (que nous appellerons ``data.csv``), on remarque que les noms de colonne sont longs.

On va raccourcir tout ça (juste pour simplifier, le script aurait très bien pu marcher sans ça ;) ) et le transformer en ::

    D;A;NbTotal;NbRetards

Maintenant que nous avons un peu retouché les données pour simplifier le script et analyser la modif que nous aurons à faire au cours du traitement, passons aux choses sérieuses

Traitement
----------

Comme d'habitude, écrivons une base :

.. code-block:: python

    #!/usr/bin/env python
    #-*-coding:utf8-*-
    #
    # File: graph.py
    # Author: Mathieu (matael) Gaborit
    #       <mat.gaborit@gmx.com>
    # Date: 2012
    # License: WTFPL

    import os
    import sys

    # Module pour les fichiers CSV
    import csv
    
    # Module pour le graphe
    # Ici, juste la classe pour les histogrammes
    from svg.charts import bar


    # Fichier d'entrée
    FILENAME = 'data.csv'

    # Fichier de sortie (SVG)
    OUTFILE = 'ponct_TGV.svg'


    def main():
        """ Main function """ 

        # Calcul des doublons, préparation des données depuis data.csv

        # Graphe


    if __name__=='__main__':main()

Doublons et pourcentages
~~~~~~~~~~~~~~~~~~~~~~~~

Pour l'utilisation du module ``csv``, je vous renvoie à sa très bonne `doc`_.

Le code lui même est assez commenté pour être clair :

.. code-block:: python

    # initialisation d'une liste vide,
    # elle contiendra les enregistrements
    liste = []

    # ouverture du fichier CSV via le module qui va bien
    r = csv.DictReader(open(FILENAME, 'r'), delimiter=';')

    # Pour chaque ligne du fichier
    for line in r:

        # on considère qu'elle n'existe pas dans la liste
        exists = False

        # on parcourt la liste actuelle
        for i in liste:

            # si un enregistrement de la liste a :
            if i['D']==line['A']\       # même départ que l'arrivée de l'enregistrement courant
               and i['A']==line['D']:   # et même arrivée que le départ du courant

                i['NbTotal'] += line['NbTotal']     # on ajoute les deux nombres de trains
                i['NbRetards'] += line['NbRetards'] # et les nombres de retards
                exists=True # on précise ensuite que l'enregistrement à été trouvé dans la liste
                break # On sort alors du for

        # Si on a pas trouvé l'enregistrement dans la liste
        if not exists:

            # on l'y ajoute
            liste.append(line)
    
Graphe
~~~~~~

On va ensuite devoir écrire le bout de code permettant de générer le SVG final.


.. code-block:: python

    fields = []     # liste des champs (noms de trajets ici)
    retards = []    # en retard
    ok = []         # à l'heure

    # pour chaque élément de la liste
    for i in liste:
        # On ajoute un champ à la liste dans le genre :
        # Destination1 <-> Destination2
        fields.append("{} <-> {}".format(i['A'], i['D']))

        # On définit un hash contenant les différents nombres utiles
        nb = {
            'total': int(i['NbTotal']),
            'retards': int(i['NbRetards']),
            'ok': int(i['NbTotal'])-int(i['NbRetards'])
        }
        # Attention, csv ne renvoie que des str, d'où la fonction int()

        # on ajoute à la fin de la liste le pourcentage de retard pour ce trajet
        retards.append(nb['retards']/nb['total']*100)

        # idem pour le pourcentage de trains à l'heure
        ok.append(nb['ok']/nb['total']*100)


Voilà pour la préparation du terrain.
Reste à établir le graphe lui même :

.. code-block:: python
    
    # g => objet de type VerticalBar avec les champs définis plus haut
    g = bar.VerticalBar(fields)

    # options
    g.stack = 'side'                # les jeux de données seront affichés côte à
                                    # côte. Mettre 'top' pour un empilement
    g.show_graph_title = True       # On affiche le titre (il est défini en dessous)
    g.graph_title = "Pourcentage de trains à l'heure/en retard en Avril 2012 (source SNCF)"
    g.show_data_values = False      # On n'affiche pas de valeur numériques
    g.width, g.height = 1200,700    # On définit hauteur et largeur
    g.rotate_x_labels = True        # Les noms de champ (en abscisse) seront
                                    # tournés de 90° (plus lisible)
    g.scale_integers = True         # Les repères en fond seront à des nombres entiers
    g.font_size = 10                # taille de police (peu important)


    # Ajout du premier jeu de données : trains à l'heure
    g.add_data({
        'data': ok,                 # la liste contenant les données
        'title': "Trains à l'heure" # le titre (pour la légende)
    })

    # Ajout du second jeu de données : trains en retard
    g.add_data({
        'data': retards,
        'title': "Trains en retard"
    })
    
    # on ouvre le fichier de sortie en mode write et binary
    out = open(OUTFILE, 'wb');

    # on "grave" le graphe dans celui ci
    out.write(g.burn())

    # et on referme le fichier
    out.close()

Là encore, les commentaires suffisent largement pour comprendre le tout.

Reste à rendre ledit script éxécutable et à le lancer :

.. code-block:: bash

    chmod u+x ./graph.py
    ./graph.py

Pour ceux qui veulent, le `script est téléchargeable`_.

Le résultat final
=================

Enfin, on observe le résultat (en `plus grand ici`_)

.. image:: /static/images/dataporn/ponct_TGV.svg
    :width: 600px
    :align: center


Conclusion
==========

L'avantage de l'Opendata en termes d'interopérabilité est incontestable.
On arrive toutefois à un point où de plus en plus de données sont disponibles mais
difficilement compréhensibles car un peu trop *brutes*.

Heureusement, de très nombreux langages permettent de créer des représentations
graphiques beaucoup plus parlantes et ce presque sans difficultés.
Par exemple, ce script a été écrit en 5 minutes, juste pour tester.

Dans les mois et les années à venir, la maitrise d'outils permettant de
visualiser rapidement les implications d'un ensemble de données va devenir un
point critique tant dans ses applications économiques que dans l'aide qu'ils
représentent pour comprendre la société et ses évolutions.

.. _post de Denis Bodor: http://www.sncfapplilab.com/feedbacks/65286-ouvrir-les-sources-des-applications-et-creer-une-communaute-de-developpeurs
.. _SNCF Appli Lab: http://www.sncfapplilab.com/
.. _data.sncf.com: http://data.sncf.com/
.. _premiers jeux de données ouverts: http://test.data-sncf.com/ 
.. _disponible ici: http://test.data-sncf.com/index.php?p=voyages-sncf
.. _CSV: http://fr.wikipedia.org/wiki/Comma-separated_values
.. _cet article: http://blog.matael.org/writing/dataporn-part-1-stats-phpbb/
.. _doc: http://docs.python.org/library/csv.html
.. _script est téléchargeable: /static/images/dataporn/TGV.py
.. _plus grand ici: /static/images/dataporn/ponct_TGV.svg
