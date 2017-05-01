=========================================
Passer de l'ICAL au PDF : un petit script
=========================================

:date: 2015-01-04 11:28:40
:slug: passer-de-lical-au-pdf-un-petit-script
:authors: matael
:summary: Quand l'ICAL passe en liste
:tags: python, fac, ical, imported

.

    On pourra trouver bon de lire `cet article`_ pour commencer.

Après avoir trituré ADESoft pour lui soutirer des infos *via* une URL d'export iCal, on repasse à l'attaque avec cette
fois l'objectif plus ambitieux de générer un PDF.

Plan de bataille
================

Voilà comment on va procéder :

1. On trouve un moyen de récupérer l'emploi du temps en ligne
2. On trouve un moyen de générer un PDF correct
3. On assemble le tout et on voit si ça marche :)

Part 1 : Récupérer l'emploi du temps
====================================

De ce côté là, pas trop de souci. Je suis simplement allez chercher au même endroit que `la dernière fois`_. Je m'en
suis tiré avec une belle URL et *zou* :)

Récupération des données
------------------------

A noter qu'en python, l'iCal se *parse* plutot pas mal :

.. sourcecode:: python

    from icalendar import Calendar
    from urllib import urlopen

    URL = "http://planning.univ-lemans.fr:8080/ade/custom/modules/plannings/anonymous_cal.jsp?resources=5810,5804&projectId=2&calType=ical&nbWeeks=4"

    g = urlopen(URL)
    gcal = Calendar.from_ical(g.read())

et voilà que ``gcal`` contient toutes les infos ICAL qui vont bien.

Reste que tout n'est pas vraiment dans le bon ordre en l'état. Si je veux ensuite générer une liste chronologique en
PDF, ce serait quand même plus simple si tout était classé chronologiquement au début de la génération du PDF.

Nouveau type et création d'une liste
------------------------------------

On peut commencer par créer un nouveau *pseudo-type* python pour gérer nos events iCal (oui, je sais qu'il y en a déjà
un de proposé dans le module ``icalendar``, seulement, je veux un truc simple moi, un simple *tuple* amélioré, pas une
usine à gaz).

Par chance, le module ``collections`` propose un truc du genre :

.. sourcecode:: python

    from collections import namedtuple

    Vevent = namedtuple('Vevent', ['dtstart', 'dtend', 'summary', 'location'])

Je crée donc le *"type"* ``Vevent`` (qui est en fait une classe) avec les 4 champs précisés auquel je pourrais accèder
facilement. Les facilités introduites par ``collections`` on l'énorme avantage d'être hyper-efficaces : ``namedtuple``
par exemple crée une classe dont chacune des instances ne peut avoir que des attributs définis à la création de la
classe.

Ajoutons maintenant chacun des *events* iCal dans une liste (que l'on triera ensuite) :

.. sourcecode:: python

    events = []
    for component in gcal.walk():
        if component.name == "VEVENT":
            e = Vevent(dtstart=component.get('dtstart').dt,
                       dtend=component.get('dtend').dt,
                       summary=component.get('summary').encode('utf8'),
                       location=component.get('location').encode('utf8')
                      )
            events.append(e)

Voilà pour la génération de la liste elle même, on prend soin (notez le) de faire les conversion de type à ce moment là
pour les chaines (*summary* et *description*) et de retire l'objet ``datetime.datetime`` natif pour les 2 dates : ça
permettra d'allèger l'écriture ensuite.

Tri
---

Pas d'algo archi-compliqué ici : on est en python. Pour trieer une liste, il y a ``sort()`` (voire ``sorted()``).

Il faut simplement savoir que ``sort()`` qui est une méthode de liste peut prendre un argument ``key`` permettant de
renseigner une fonction qui sera appellé sur chacun des éléments à trier et donc la valeur de retour sera utilisée comme
clé de tri :

.. sourcecode:: python

    events.sort(key=lambda event: event.dtstart)

En l'occurence, on ne s'embète pas et on place une *lambda-function* dans ``key`` qui a pour utilité de renvoyer
l'objet ``datetime.datetime`` représentant le début du cours. Le module ``icalendar`` ayant le bon gout de traduire les
dates iCal par des objets natifs, on peut les comparer allègrement.

Les cours sont maintenant triés par ordre croissant des dates ; reste à les afficher et surtout à générer un PDF.

Part 2 : Génération d'un PDF
============================

Bon, soyons francs, le format PDF est une horreur quand il s'agit de bosser avec. Même en utilisant une *lib* ça reste
vicieux et retors. On va donc tricher (eh, il est dimanche hein). On va :

1. générer un fichier temporaire et écrire dedans notre *listing* en utilisant le format RestructuredText
2. faire passer ``rst2pdf`` par dessus et générer ainsi le PDF final
3. supprimer le fichier ReST temporaire

Fichier ReST temporaire
-----------------------

Rien de bien compliqué :

.. sourcecode:: python

    from os import system, getpid, remove

    # plutot que m'embèter avec les dates, j'ajoute l'offset à UTC à la main
    UTC_OFFSET = 1

    # génération d'un nom de fichier temporaire à partir
    # du pid du script
    fn = 'ical2pdf'+str(getpid())+'.rst'

    # ouverture
    fh = open(fn, 'w')

    # titre
    fh.write('===============\n')
    fh.write('Emploi du Temps\n')
    fh.write('===============\n\n')

    # boucle sur les events triés
    previous_d = 0
    for e in events:

        # création d'une nouvelle section si la date à
        # changé par rapport à l'élément d'avant
        if previous_d != e.dtstart.date():
            l = len(str(e.dtstart.date()))

            # écriture du titre de section
            fh.write('\n'+str(e.dtstart.date())+'\n'+'='*l+'\n')

            previous_d = e.dtstart.date()

        # écriture de l'élément courant
        fh.write("- **[ "+e.location.capitalize().split(' ')[0]+" ] ")
        fh.write(str(e.dtstart.hour+UTC_OFFSET)+':'+str(e.dtstart.minute)+"**-"+str(e.dtend.hour+UTC_OFFSET)+':'+str(e.dtend.minute)+" ")
        fh.write(e.summary.capitalize()+'\n')

    fh.close()

Génération du PDF et suppression du ReST
----------------------------------------

Une fois que notre magnifique fichier ReST est complet, il ne reste qu'a faire passer ``rst2pdf`` dessus.

Vous pouvez installer ce superbe script comme suit :

.. sourcecode:: bash

    sudo pip install reportlab rst2pdf

Bien sûr, vous veillerez à bien utiliser ``pip`` ou ``easy_install`` pour un python2.6 ou 2.7 et non 3.x...

Une fois qu'on a notre ``rst2pdf`` fonctionnel, on fait quelque chose d'atroce : un appel à ``os.system()`` :

.. sourcecode:: python

    system('rst2pdf --output=./'+str(getpid())+'.pdf '+fn)

    # on supprime le ReST
    remove(fn)


Ceci étant fait, on a un joli PDF contenant le listing tant attendu \\o/.

Le script complet
=================

Voilà le script en entier pour ceux qui préfèrent tout lire d'un coup :

.. sourcecode:: python

    from icalendar import Calendar
    from urllib import urlopen
    from collections import namedtuple
    from os import system, getpid, remove

    # fetch data

    URL = "http://planning.univ-lemans.fr:8080/ade/custom/modules/plannings/anonymous_cal.jsp?resources=5810,5804&projectId=2&calType=ical&nbWeeks=4"
    UTC_OFFSET = 1

    print('Fetching ICAL file')

    g = urlopen(URL)
    gcal = Calendar.from_ical(g.read())

    # sort events

    print('Sorting events')

    Vevent = namedtuple('Vevent', ['dtstart', 'dtend', 'summary', 'location'])

    events = []
    for component in gcal.walk():
        if component.name == "VEVENT":
            e = Vevent(dtstart=component.get('dtstart').dt,
                       dtend=component.get('dtend').dt,
                       summary=component.get('summary').encode('utf8'),
                       location=component.get('location').encode('utf8')
                      )
            events.append(e)

    events.sort(key=lambda event: event.dtstart)

    # Output

    fn = 'ical2pdf'+str(getpid())+'.rst'
    print('Generating ReST file (tempfile: ./'+fn)

    fh = open(fn, 'w')

    fh.write('===============\n')
    fh.write('Emploi du Temps\n')
    fh.write('===============\n\n')

    previous_d = 0
    for e in events:
        if previous_d != e.dtstart.date():
            l = len(str(e.dtstart.date()))
            fh.write('\n'+str(e.dtstart.date())+'\n'+'='*l+'\n')
            previous_d = e.dtstart.date()

        fh.write("- **[ "+e.location.capitalize().split(' ')[0]+" ] ")
        fh.write(str(e.dtstart.hour+UTC_OFFSET)+':'+str(e.dtstart.minute)+"**-"+str(e.dtend.hour+UTC_OFFSET)+':'+str(e.dtend.minute)+" ")
        fh.write(e.summary.capitalize()+'\n')

    fh.close()

    print('End of ReST output')
    print('Compiling to PDF')

    system('rst2pdf --output=./'+str(getpid())+'.pdf '+fn)

    print('Removing temp file')
    remove(fn)

Bien sûr, vous pourrez tout retrouver sur github_ !


.. _la dernière fois:
.. _cet article: http://blog.matael.org/writing/ade-campus-et-bash/
.. _github: https://github.com/Matael/ical2pdf
