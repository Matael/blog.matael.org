==============================================
Un micro-planet pour Sphinx en moins de 30sloc
==============================================

:date: 2015-01-04 11:28:43
:category: imported
:slug: un-micro-planet-pour-sphinx-en-moins-de-30sloc
:authors: matael
:summary: Keep It Simple, Stupid... et ça marche.
:tags: python, haum

Un peu de contexte... Le HAUM a un `site web`_ et, il y a quelque temps, s'est posée la question de ramener sur le site
les liens vers les articles de blogs parlant de nous.

Alors certes, c'est un bête planet_ me direz vous. Mais voyez-vous, je suis pas particulièrement pour charger le serveur
avec un nouveau site... surtout quand on a pas des dizaines de blogs à parser. On a décidé de partir sur un "cahier des
charges" tacite et hyper-simple :

- la solution doit s'intégrer facilement dans le site existant ;
- le côté dynamique peut être réalisé sans problème à la main ou par simple *crontask* (pour le lancement de la
  récupération) ;
- la solution doit être **simple** ;
- on doit pouvoir rajouter facilement des blogs quelque soit l'interface fournie par ceux ci.

De mon point de vue, un truc tout simple pouvait répondre à ça : un script. Un script tout bête.

Archi générale
==============

Avant de me lancer dans le code, je me suis demandé comment satisfaire à la possibilité d'une extension rapide des
sources d'articles... En me souvenant d'une fonction de Python que je n'avais plus utilisée ainsi depuis longtemps, j'ai
décidé que l'archi ressemblerait à ::

    sphinx_dir
    ├── build
    │   └── html
    └── source
        ├── page1.rst
        ├── page2.rst
        ├── planet.rst
        └── planet
            ├── fetchall.py
            └── sources
                ├── __init__.py
                ├── source1.py
                └── source2.py

Ainsi, dans le même dossier que les pages actuelles je rajoute un dossier ``planet`` qui contiendra tout le nécessaire :

- les sources sous forme de modules dans ``sources/``
- le script ``fetchall.py`` qui appelle une fonction ``fetch()`` sur chacun des modules du répertoire ``sources/`` et qui
  gènère la page ``planet.rst``

Dans l'ordre, je vous montre d'abord les scripts sources puis le script général (qui fera moins de 30 lignes de code effectif).

Sources !
=========

Les sources sont de simples scripts qui récupèrent les titres et URL d'articles sur un site donné.
Si le blog possède un `flux RSS`_ (comme le mien), alors, il suffit d'appeler ``feedparser`` à la rescousse par exemple.
Sinon, on code de quoi récupérer la liste (on verra un exemple avec le `blog de feedoo`_).

On va s'arranger pour que les fonctions ``fetch()`` des sources répondent à 2 specs :

- elles n'ont pas besoin de paramètres
- elles renvoient une liste de tuples : ``(titre, url, auteur)``

Un blog avec un flux RSS
------------------------

Rien de plus simple. On va, par exemple, récupérer les articles de mon blog, taggés avec **haum**. Pour ça, il y a un flux RSS à
l'adresse http://blog.matael.org/writing/tagged/haum/feed/ .

Donc c'est parti :

.. sourcecode:: python

    import feedparser as fp

    SOURCE_URL = 'http://blog.matael.org/writing/tagged/haum/feed'

    def fetch():
        return [(_['title'], _['link'], 'Mathieu (matael)') for _ in fp.parse(SOURCE_URL)['entries']]

Je vous avais prévenus : c'est simple. La dernière ligne fait, vous l'aurez compris, tout le boulot. C'est une bonne
vieille *list comprehension* et qui formate correctement la sortie du parser de flux (pour savoir pourquoi je récupère
l'élément ``entries`` après le *fetch* regardez la structure du flux RSS...).

Un blog sans RSS
----------------

Alors, là, c'est plus velu... non, j'déconne.

Sur son blog, feedoo_ n'a pas de flux RSS mais il a tout de même des pages de catégorie. Si on regarde, celle pour la
catégorie "haum" est à l'adresse : http://blog.fredblain.org/tag/haum

    **EDIT :** feedoo me fait remarquer qu'il a bel et un un flux RSS mais que celui ci est global (et pas propre à une
    catégorie). A noter qu'en prenant ça en compte, on aurait pu le récupérer avec ``feedparser`` et filtrer ensuite pour
    n'avoir que le tag *haum*

En lisant le code de cette page, on remarque que les titres d'article sont tous dans une balise ``h2`` portant la classe
``title-index`` et contenant un lien vers l'article lui-même. Un bon coup de BeautifulSoup pour mâcher le HTML et on
récupère ce qu'il nous faut :

.. sourcecode:: python

    from  bs4 import BeautifulSoup
    import requests

    SOURCE_URL = "http://blog.fredblain.org/tag/haum"

    def fetch():
        soup = BeautifulSoup(requests.get(SOURCE_URL).text)

        return [(
            _.find('a').text,
            _.find('a').get('href'),
            'Fred (feedoo)'
        ) for _ in soup.findAll('h2', {'class': 'title-index'})]

Là aussi la dernière ligne (qui est splittée pour des raisons de lisibilité) fait tout le boulot... allez, je l'explique
 (de la fin vers le début):

.. sourcecode:: python

    for _ in # la variable _ prendra tour à tour chacun
             # des éléments dans la fonction ci dessous

    soup.findAll('h2', {'class': 'title-index'})  # dans la soupe, chercher toutes les balises
                                                  # h2 assorties d'une classe title-index
    # avec tous ces éléments, on construit ce genre de tuple :
    (
        _.find('a').text,           # le texte du lien (titre du post)
        _.find('a').get('href'),    # la cible du lien
        'Fred (feedoo)'             # l'illustre auteur
    )

Et... voilà !

Vous n'allez pas me dire que c'était compliqué !

Le gros méchant script
======================

On va se fendre la gueule... je vous explique rapidement le concept. Dans l'ordre, le script va récupérer les
différents liens pour les posts via les fonctions ``fetch()`` et tout écrire dans un fichier. Une fois n'est pas
coutume, on va commencer par la fin (parce que c'est plus simple) : l'affichage.


.. sourcecode:: python

    # le fichier dans lequel on écrit
    OUTPUT_FILE = '../planet.rst'

    # le début du fichier
    # (pour pas attaquer direct sur la liste)
    HEADER = """
    Planet
    ======

    Voilà ceux qui parlent de nous sur leurs blogs

    """

    def output(f_res):
        # f_res : fetch results

        # on ouvre le fichier
        with open(OUTPUT_FILE, 'w') as out:
            out.write(HEADER) # on y colle le header

            # pour chaque source
            for r in f_res:
                # r[0] est le titre (on en fait un lien anonyme avec __)
                # et on ajoute "par Auteur"
                out.write('`'+r[0]+'`__ par '+r[2]+'\n')
                # on trace une ligne de --- à la bonne longueur en dessous
                # pour en faire un titre en reStructuredText
                out.write('-'*(9+len(r[0]+r[2]))+'\n\n')
                # on laisse passer deux lignes et on ajoute la cible du lien
                # anonyme de tout à l'heure
                out.write('__ '+r[1]+'\n\n')


Voilà pour la partie affichage.

Maintenant on se colle à la fonction ``main()`` qui fait tout le boulot de récupération groupée.


.. sourcecode:: python

    from glob import glob

    # ...

    def main():
        # récupère la liste des scripts sources
        # et lance la fonction fetch()
        # puis met en forme

        # liste qu'il faut remplir
        fetch_results = []

        #  pour chaque .py du dossier sources/
        for i in glob('sources/*.py'):

            # sauf si c'est le __init__.py
            if i!='sources/__init__.py':

                # on remplace le / par un . et on vire le .py ensuite
                # on utilise alors __import__ pour importer le module choisi
                a = __import__(i.replace('/','.').replace('.py',''))

                # un peu tricky, le module lui même est stocké dans l'objet a, en face
                # d'une clé qui porte le nom du module sans 'sources/' et '.py'
                # on le récupère avec __getattribute__ et on appelle directement .fetch()
                # on concatène alors la liste retournée avec les résultats précédents
                fetch_results += a.__getattribute__(i.replace('sources/','').replace('.py','')).fetch()

        # un petit coup d'output
        output(fetch_results)

    # pour lancer main() si le module est éxécuté directement
    if __name__=='__main__':main()

Donc voilà. J'aimerais vous dire : regardez, c'est super simple, mais ce serait mentir.

C'est pas *très* compliqué, mais ce bout du code utilise des fonctions *bas niveau* de Python. D'abord la primitive
``__import__``, qui permet l'import d'un module et qui renvoie un objet référençant les modules importés. Ensuite le
``__getattribute__`` qui est un moyen de récupèrer un attribut d'un objet quel qu'il soit. Cette fonction est quasiment
toujours définie mais n'est pas vraiment faite pour être utilisée en direct.

Si on met tout ensemble (sans les commentaires ajoutés) :

.. sourcecode:: python

    from glob import glob

    OUTPUT_FILE = '../planet.rst'

    HEADER = """
    Planet
    ======

    Voilà ceux qui parlent de nous sur leurs blogs

    """

    def output(f_res):
        # f_res : fetch results

        with open(OUTPUT_FILE, 'w') as out:
            out.write(HEADER)

            for r in f_res:
                out.write('`'+r[0]+'`__ par '+r[2]+'\n')
                out.write('-'*(9+len(r[0]+r[2]))+'\n\n')
                out.write('__ '+r[1]+'\n\n')


    def main():
        # récupère la liste des scripts sources
        # et lance la fonction fetch()
        # puis met en forme

        fetch_results = []

        for i in glob('sources/*.py'):
            if i!='sources/__init__.py':
                a = __import__(i.replace('/','.').replace('.py',''))
                fetch_results += a.__getattribute__(i.replace('sources/','').replace('.py','')).fetch()

        output(fetch_results)


    if __name__=='__main__':main()

Et si vous comptez les lignes (sans les lignes blanches), vous arrivez à **28 lignes** !
Et pour vous prouver que ça marche : http://haum.org/planet.html

Qu'est ce que ça a de si cool ?
===============================

D'abord c'est minimaliste et rien qu'en soi, c'est cool.

Ensuite, l'ajout d'une nouvelle source est simpliste, et le script général est court et pas trop alambiqué.
Le fait de pouvoir ajouter plein de sources quelque soit leur format est plutôt cool et c'est pas faisable sur tous les
"gros" planets.

Enfin, la charge sur le serveur est nulle en dehors du moment où le script est lancé.

Automatisation
==============

Finalement, pour que la mise à jour soit quasi automatique, on a ajouté le lancement du script dans le *hook* git de
*post-merge*. A chaque ``git pull`` sur le serveur le planet est mis à jour. On peut aussi le mettre à jour "manuellement" via le
`chan IRC`_ et un bot (le même qui permet de mettre à jour le site).

Et voilà pour un bout de code pas long mais bien utile :)

.. _site web: http://haum.org
.. _planet: http://fr.wikipedia.org/wiki/Planet
.. _flux RSS: http://fr.wikipedia.org/wiki/RSS
.. _blog de feedoo: http://blog.fredblain.org/
.. _feedoo: http://twitter.com/fblain
.. _BeautifulSoup: http://www.crummy.com/software/BeautifulSoup/bs4/doc/
.. _chan IRC: http://irc.lc/freenode/haum/blogreader@@
