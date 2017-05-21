#!/usr/bin/env python
#-*-coding:utf8-*-
#
# File: TGV.py
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

    # initialisation d'une liste vide,
    # elle contiendra les enregistrements
    liste = []

    # ouverture du fichier csv via le module qui va bien
    r = csv.dictreader(open(filename, 'r'), delimiter=';')

    # pour chaque ligne du fichier
    for line in r:

        # on considère qu'elle n'existe pas dans la liste
        exists = false

        # on parcourt la liste actuelle
        for i in liste:

            # si un enregistrement de la liste a :
            if i['d']==line['a']\       # même départ que l'arrivée de l'enregistrement courant
               and i['a']==line['d']:   # et même arrivée que le départ du courant

                i['nbtotal'] += line['nbtotal']     # on ajoute les deux nombres de trains
                i['nbretards'] += line['nbretards'] # et les nombres de retards
                exists=true # on précise ensuite que l'enregistrement à été trouvé dans la liste
                break # on sort alors du for

        # si on a pas trouvé l'enregistrement dans la liste
        if not exists:

            # on l'y ajoute
            liste.append(line)

    # Graphe

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


if __name__=='__main__':main()
