==================================
Datalove et les parkings de Nantes
==================================

:date: 2015-01-04 11:28:40
:slug: datalove-et-les-parkings-de-nantes
:authors: matael
:summary: Graph over OpenData
:tags: python, matplotlib, datalove, imported

Au dernier Jelly manceau, le HAUM avait squatté une table et bidouillé des trucs toute la journée.

En plus de tout ça, pas mal de discussions ont tourné (c'était un peu l'objectif de la journée) autour de sujets
divers, dont l'OpenData.

Il faut savoir que ces dernières années, la région Pays De la Loire (PDL pour les intimes) s'est mise à l'OpenData.
On accède aux données *via* le portail_ dédié et on peut faire *joujou* ensuite avec les jeux de données proposés.

.. image:: /static/images/dataporn/places.png
    :align: center

Nous reviendrons sur 3 points au long de l'article :

- l'accès aux données et l'obtention d'une clé API
- le bricolage d'un script d'exemple d'utilisation
- quelques remarques sur l'initiative et le portail en lui même

Accès
=====

Une fois arrivé sur le portail_ OpenData de la région, je vous conseille de créer un compte.

Une fois celui-ci activé, vous pourrez vous connecter et trouver, dans la rubrique **Mon compte > Nouvelle Application**
un formulaire pour créer une nouvelle appli.

A l'envoi du formulaire, une clé d'API vous sera comuniquée. Vous pourrez aussi la retrouver dans **Mon compte > Liste
de mes applications**.

L'étape suivante consiste à ... lire cette foutue doc !

En fait, une page en particulier «explique» le `fonctionnement de l'API`_ et une autre comment choisir le `format de
retour`_.

Deux autres pages sont vraiment utiles :

- la page expliquant la licence_ ODbL utilisée pour les données
- la page des `données`_

Je vous conseille de les parcourir pour vous faire une idée de ce qui y est dit.

Exemple de commande : les parkings
----------------------------------

Pour l'accès aux données temps réel des parkings, on commence par regarder `cette page`_.

On y apprend (entre autres) le nom de la commande correspondante : ``getDisponibiliteParkingsPublics``.
L'URL d'appel sera donc : http://data.nantes.fr/api/getDisponibiliteParkingsPublics/1.0/MA_CLE_API/?output=json
(pour un retour en JSON).

Cette `autre page`_ décrit les données renvoyées : pour un graphe du taux de remplissage par parking, nous aurons
besoin de ``Grp_nom`` et ``Grp_disponible`` et ``Grp_exploitation``.

Script
======

Bien sûr, nous ferons tout ça en Python (parce que le python, c'est cool).

Une partie des commentaires du code sont en anglais, en effet, j'ai codé ce script et commenté en anglais (comme souvent) et je
n'ai pas eu envie de traduire.

Attention enfin, ce script est fait en **Python 3**. Si quelqu'un a une version pour Python 2.7 à proposer, je
l'ajouterais volontiers à l'article.

Commençons par le commencement : les *imports*.

.. code-block:: python

    # pour le exit() en cas d'erreur
    import sys
    # pour l'accès au résultat
    from json import loads
    # dialogue avec l'API
    from urllib.request import urlopen
    # graphe
    from matplotlib import pyplot as plt


    def main():

        # faire des trucs...

    if __name__=='__main__': main()

Reste à remplir notre ``main()``. D'abord, quelques infos nous concernant :

.. code-block:: python

    api_key = 'MA_CLE_API' # mettez la votre
    base_url = 'http://data.nantes.fr/api/'
    command = 'getDisponibiliteParkingsPublics/1.0/'
    format = '/?output=json'

    # recreate full url
    full_url = "{}{}{}{}".format(
        base_url,
        command,
        api_key,
        format
    )

On va chercher les données en ligne et quitter en cas d'erreur :

.. code-block:: python

    # get the data :
    data_handle = urlopen(full_url)

    # convertir en python
    data = loads(data_handle.read().decode())

    # handle eventual errors
    # les erreurs éventuelles sont détaillées dans le retour
    if data['opendata']['answer']['status']['@attributes']['code'] != "0":
        # on affiche le message d'erreur retourné
        print("A error occured :\n\n{}".format(
            data['opendata']['answer']['status']['@attributes']['code']
        ))
        sys.exit(1)

On raccourcit un peu la chaîne de dicos générée par l'API et on récupère les données nous intéressant :

.. code-block:: python

    # shorten a bit this fucking hash-ception
    parkings = data['opendata']['answer']['data']['Groupes_Parking']['Groupe_Parking']

    # extract places
    lien_nom_places = {}
    for _ in parkings:
        if _['Grp_exploitation'] == '0':
            lien_nom_places[_['Grp_nom']] = 100
        else:
            lien_nom_places[_['Grp_nom']] = \
                    100.0-(int(_['Grp_disponible'])/int(_['Grp_exploitation']))*100

    # on sépare noms et places tout en gardant le lien de l'indice :
    # noms[i] correspond à places[i]
    noms = [_ for _ in lien_nom_places.keys()]
    places = [lien_nom_places[_] for _ in noms]


Une première version du script utilisait les *Dict-comprehension* pour remplir le dico ``lien_nom_places``, voilà la
ligne qui était utilisée :

.. code-block:: python

    lien_nom_places = {_['Grp_nom']:
                       (100.0-(int(_['Grp_disponible'])/int(_['Grp_exploitation']))*100)
                       for _ in parkings}

Le codeur remarquera qu'avec ce genre de contruction, on parie sur le fait que ``_['Grp_exploitation']`` ne sera jamais
nul, ce qui est faux. Dans la nouvelle version, si ce champ est nul, on considère qu'il ne reste plus de places et on
passe la valeur du dico à 100 (remplissage à 100%).

Dict-what ?
-----------

*Dict-comprehension*. Il y a une page là-dessus ici : PEP274_.

En gros, si vous connaissez un peu les *list-comprehensions*, ce n'est pas beaucoup plus compliqué.

Avec les *list-comprehensions* (deux dernières lignes du code précédent), vous pouviez faire :

.. code-block:: python

    noms = [_ for _ in lien_nom_places.keys()]

Et cela créait alors une vraie liste contenant les clés du dico ``lien_nom_places``.

Les dict-comprehensions étendent cette syntaxe condensée aux dictionnaires. Par exemple, pour inverser clés et valeurs
d'un dico ``a`` (les valeurs deviennent les clés et leur clé leur valeur) :

.. code-block:: python

    b = { a[k]:k for k in a.keys()}

Et ``b`` est alors le dico inversé.

Ici, on met comme clé le nom du parking (unique) et comme valeur un pourcentage.

.. code-block:: python

    lien_nom_places = {_['Grp_nom']:
                       (100.0-(int(_['Grp_disponible'])/int(_['Grp_exploitation']))*100)
                       for _ in parkings}

La deuxième ligne prend 100 et y retranche le pourcentage de places libres (``(int(_['Grp_disponible'])/int(_['Grp_exploitation']))*100``).
L'utilisation de la fonction ``int()`` (deux fois) ne facilite pas la lecture mais c'était toutefois nécessaire, l'API ne renvoyant que des chaînes.

Reste à créer le graphe qui va bien (admirable en haut de page) :

.. code-block:: python

    # recreer un axe des abscisses
    width = 0.8 # width of a bar
    left = [_*width for _ in range(len(places))]

    # le bargraph en lui-même
    plt.bar(left, places, width=width)

    # les noms des parkings
    plt.xticks(left, noms, rotation=85)

    # la grille
    plt.grid('on')

    # le titre
    plt.title("Pourcentage de remplissage des parkings de Nantes")

    # ajustement au plus proche de l'image sans la rogner
    plt.tight_layout()

    # sauvegarde !!
    plt.savefig('places')

Finalement, une petite soixantaine de lignes bien aérées pour arriver à un joli graphe, c'est honnête.

Script complet
--------------

Pour ceux qui préfèrent lire au kilomètre :

.. code-block:: python


    #!/usr/bin/env python
    #-*- coding: utf8 -*-

    import sys
    import os
    from json import loads
    from urllib.request import urlopen
    from matplotlib import pyplot as plt

    def main():

        api_key = '5H7IGDGF78UQAOF'
        base_url = 'http://data.nantes.fr/api/'
        command = 'getDisponibiliteParkingsPublics/1.0/'
        format = '/?output=json'

        # recreate full url
        full_url = "{}{}{}{}".format(
            base_url,
            command,
            api_key,
            format
        )

        # get the data :
        data_handle = urlopen(full_url)
        data = loads(data_handle.read().decode())

        # handle eventual errors
        if data['opendata']['answer']['status']['@attributes']['code'] != "0":
            print("A error occured :\n\n{}".format(
                data['opendata']['answer']['status']['@attributes']['code']
            ))
            sys.exit(1)

        # shorten a bit this fucking hash-ception
        parkings = data['opendata']['answer']['data']['Groupes_Parking']['Groupe_Parking']


        # extract places
        lien_nom_places = {_['Grp_nom']:
                           (100.0-(int(_['Grp_disponible'])/int(_['Grp_exploitation']))*100)
                           for _ in parkings}
        noms = [_ for _ in lien_nom_places.keys()]
        places = [lien_nom_places[_] for _ in noms]

        # recreate a x-axis
        width = 0.8 # width of a bar
        left = [_*width for _ in range(len(places))]

        plt.bar(left, places, width=width)
        plt.xticks(left, noms, rotation=85)
        plt.grid('on')
        plt.title("Pourcentage de remplissage des parkings de Nantes")

        plt.tight_layout()

        plt.savefig('places')

    if __name__=='__main__': main()

**Feel free to hack that script :** https://gist.github.com/4651025 **!**

Remarques
=========

C'est donc assez cool d'avoir accès à un peu de données concernant la région.

Eternel instatisfait, j'ai quand même quelques remarques à formuler :

- Le site est **anti-ergonomique** au possible. Je me perds courament dedans, c'est un véritable dédale et on a du mal à
  trouver l'info recherché rapidement.
- Certains **bugs** du site sont assez étranges (problèmes de connexion, liens morts en interne, pages d'erreur bizarres,
  etc....). Pas forcément une bonne chose...
- Le **design** est soit trop limité pour un site de promotion soit trop développé/coloré pour une doc. Si on veut une
  simple doc présentée clairement, un truc façon ReadTheDocs_ serait encore le mieux.

Il y a aussi des bons points non négligeables :

- proposer plusieurs formats est un très bon point. Proposer un outil permettant de visualiser les jeux *à la volée*
  serait la panacée.
- le fait de proposer des clés étrangères liant les jeux est une excellente chose qui sera utile pour recouper les
  données entre elles au besoin.
- les données temps réel sont un vrai plus. Mais, messieurs/dames les concepteurs(trices), pourquoi ne pas avoir
  proposé de *Streaming API* pour ça ?

Finalement, l'initiative semble plutôt bien partie ! Reste à ce que le nombre de jeux de données augmente encore un peu
et que les entrepreneurs s'y mettent.

Enfin, il faudra aussi que la *région tout entière* s'y mette, parce que pour l'instant, c'est très *Nantes-centric*.

Alors ? Le Mans, Angers, La Roche s/ Yon ? Quand est ce que vous rejoignez le mouvement ?

*PS: non, les petits portails opendata maison comme* `celui du Mans`_ *ne comptent pas. Si on fait un truc régional alors,
faut que tout le monde s'y mette !*

*PPS : merci à A. la relectrice !*


.. _portail: http://data.paysdelaloire.fr/accueil/
.. _fonctionnement de l'API: http://data.paysdelaloire.fr/donnees/fonctionnement-de-lapi/documentation-de-lapi/
.. _format de retour: http://data.paysdelaloire.fr/donnees/choix-des-formats/
.. _licence: http://data.paysdelaloire.fr/licence/
.. _données: http://data.paysdelaloire.fr/donnees/
.. _cette page: http://data.paysdelaloire.fr/donnees/detail/disponibilite-dans-les-parkings-publics-de-nantes-metropole/
.. _autre page: http://data.paysdelaloire.fr/donnees/fonctionnement-de-lapi/getdisponibiliteparkingspublics/
.. _PEP274:  http://www.python.org/dev/peps/pep-0274/
.. _ReadTheDocs: https://readthedocs.org/
.. _celui du Mans: http://www.lemans.fr/page.do?t=2&uuid=16CB26C7-550EA533-5AE8381B-D7A64AF8

