==================
ADE Campus et bash
==================

:date: 2015-01-04 11:25:42
:slug: ade-campus-et-bash
:authors: matael
:summary: 
:tags: bash, fac, ical, imported

La fac où je suis dispose (comme de nombreuses facs de France
d'ailleurs) de la plateforme `ADE
Campus`_ qui
permet la mise à disposition des emplois du temps

Je me suis dis que ce serait cool de pouvoir les récupèrer et les
afficher via ``inotify``, ou même les entrer dans un bot irc.

*Note : certaines lignes de code sont coupées pour rentrer dans la page,
ne faites pas attention ;)*

----------------------------
L'API qui n'en était pas une
----------------------------

Je me suis déplacé, histoire de savoir si il y avait un accès possible
vers une API.

On m'a répondu que non (parce que l'univ' n'avait pas acheté le
module...). Par contre, m'a-t-on informé, il y a un moyen de récupérer
une URL vers un fichier **ics** (*ical*).

Je suis donc reparti avec cette magnifique information et je n'ai pas
mis bien longtemps à retrouver ladite URL, qui ressemble à ça :

::

    http://mon.domaine.truc:8080/ade/custom/modules/plannings/
    `->    anonymous_cal.jsp?resources=260,486&projectId=1&calType=ical&nbWeeks=4

Si on détaille un peu cette ligne, on repère que :

-  on donc récuperer un ensemble de ressources (``ressources=260,486``)
-  on va récupérer un fichier de type **ics** (``calType=ical``)
-  on aura les ressources (comprendre les évènements) sur 4 semaines
   (``nbWeeks=4``)

Pour ce qui est de l'option ``projectId=1``, je n'ai pas cherché à
savoir ce que c'est.

----------------
Le script *kitu*
----------------

Voilà le script que j'ai biouillé pour récupérer les infos qui
m'intéressaient :

.. code-block:: bash

    #!/bin/bash
    #
    # file : extract.sh
    # author : mathieu (matael) gaborit
    # date : mar. 2012
    # license: WTFPL
    #
    # Script d'extraction de données
    # depuis un fichier ical.
    #
    # Testé avec ADECampus, Univ. du Maine

    ade_url='http://mon.domaine.truc:8080/ade/custom/modules/plannings/anonymous_cal.jsp?resources=260,486&projectId=1&calType=ical&nbWeeks=4'
    patterns="DTSTART DTEND SUMMARY LOCATION DESCRIPTION"

    curl $ade_url | grep -F "$(echo $patterns | tr ' ' '\n')" |
            tr ' ' '~ ' |
            tr ':' ' ' |
            sed -e 's/(.*$//g' |
            awk '
                /DTSTART/ { print "\n------\n\nDébut " $2}
                /DTEND/ { print "Fin " $2}
                /SUMMARY/ { print "Résumé " $2}
                /LOCATION/ { print "Lieu " $2}
                /DESCRIPTION/ { print "Description " $2}
            ' |
            sed -e 's/ /\n\t/' | sed -e 's/\(\\n\|~\)/ /g' |
            sed -e 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)T\([0-9]\{2\}\)
               \([0-9]\{2\}\)\([0-9]\{2\}\)Z/Le \3\/\2\/\1 à \4h\5/g'

Ce truc est un peu bourrin (je pense que le formattage y est pour
quelque chose, quelle idée de con de vouloir parser de ics en bash ;)).

Reprenons calmement *pipe* par *pipe*.


Note: Le *pipe* (``|``)

Crée un nouveau processus (celui de droite) dont l'**entrée standard**
correspond avec la **sortie standard** du processus de gauche.


.. code-block:: bash

    curl $ade_url |

On récupère en ligne le fichier ics à traiter


.. code-block:: bash

    grep -F "$(echo $patterns | tr ' ' '\n')" |

On ne garde que les lignes qui nous intéressent, *i.e.* celle commençant
par un des motifs suivants (ceux entre guillemets) :

.. code-block:: bash

    patterns="DTSTART DTEND SUMMARY LOCATION DESCRIPTION"

L'option ``-F`` de ``grep`` permet de chercher les lignes matchant un
certains nombre de sous-chaines (**attention, ce ne sont PAS des
regex**).

``-F`` attend une liste de sous-chaines séparés par un saut de ligne
(``\n``), d'ou le ``tr`` qui ici permet de remplacer les espaces par des
sauts de lignes. Le résultat est passé sous forme de chaine à ``grep``
(d'où le ``$(...)``).


.. code-block:: bash

    tr ' ' '~ ' |   

J'avais besoin de protéger les espaces existants, je les remplace donc
par un symbole ``~`` que je ne risque pas de trouver dans le fichier.


.. code-block:: bash

    tr ':' ' '  |

Dans la suite, j'utilise ``awk`` dont le délimiteur par défaut est une
espace, aussi remplace-je les ``:`` séparant les 2 champs à traiter par
un espace pour alléger le script ``awk``.


.. code-block:: bash

    sed -e 's/(.*$//g' |

Certaines lignes (celles commençant par *"DESCRIPTION"*) comprenait à
leur fin un truc parenthèsé qui était moche et ne me servait pas, je le
vire donc.

Si on "traduit" la *regex* ci dessus, on trouve *"remplacer (``s``) tout
(``.*``) ce qui l'y a après la première parenthèse ouvrante (``(``) par
rien"*.


.. code-block:: bash

    awk '
        /DTSTART/       { print "\n------\n\nDébut " $2}
        /DTEND/         { print "Fin " $2}
        /SUMMARY/       { print "Résumé " $2}
        /LOCATION/      { print "Lieu " $2}
        /DESCRIPTION/   { print "Description " $2}
        ' |

Les mots de gauche sont remplacés par ceux de droite, le ``$2`` servant
à remettre le second champ (après le ``:`` qu'on a remplacé par une
espace tout à l'heure) à la fin de la ligne.


.. code-block:: bash

    sed -e 's/ /\n\t/' |

On fait un bout de formatage : l'espace séparant les deux champs est
maintenant remplacé par un saut de ligne et une tabulation (``\t``).


.. code-block:: bash

    sed -e 's/\(\\n\|~\)/ /g' |

Les sauts de ligne présents depuis le début (codés "en dur" dans le
fichier) et les *tilde* (``~``) sont remplacés par une espace.

Notez que j'ai protégé le premier backslash (devant le ``n``) en
réalité, je ne veux pas matcher le saut de ligne mais bien la
sous-chaine ``\n``.


.. code-block:: bash

    sed -e 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)T\([0-9]\{2\}\)
       \([0-9]\{2\}\)\([0-9]\{2\}\)Z/Le \3\/\2\/\1 à \4h\5/g'

Celle là, elle pique. Allons y doucement

.. code-block:: bash

    sed -e              # on lance la commande sed avec l'expression suivante :
        's/             # remplacer
        \([0-9]\{4\}\)  # 4 chiffres (et les retenir)
        \([0-9]\{2\}\)  # puis 2 chiffres (et les retenir)
        \([0-9]\{2\}\)  # puis 2 chiffres (et les retenir)
        T               # puis un 'T'
        \([0-9]\{2\}\)  # puis 2 chiffres (et les retenir)
        \([0-9]\{2\}\)  # puis 2 chiffres (et les retenir)
        \([0-9]\{2\}\)  # puis 2 chiffres (et les retenir)
        Z               # puis un 'Z'
        /               # par
        Le \3           # 'Le ' suivi du 3ème motif retenu
        \/              # suivi d'un '/'
        \2              # suivi du 2ème motif retenu
        \/              # suivi d'un '/'
        \1              # suivi du 1er motif retenu
         à              # suivi de ' à '
        \4              # suivi du 4ème motif retenu
        h               # suivi de ' h '
        \5              # suivi du 5ème motif retenu
        /g'             # le tout de manière globale (plusieurs fois /ligne si besoin)

On "retient" un motif en l'entourant de ``\(`` et ``\)``. Notez par
ailleurs que je ne réutilise pas le motif 6, les parenthèses seraient
donc optionnelles.

**Que fait cette chose ?**

Ça transforme une date de ce format :

::

    20120327T06450000Z

Vers celui ci

::

    Le 27/03/2012 à 06h45 

Et croyez moi, j'étais un peu rouillé niveau regexs, là, ça a piqué !

----------
Conclusion
----------

Parfois, il n'est pas utile de sortir un langage hyper-évolué, ce cas
est un exemple parmi d'autres.

Notons tout de même que je vais essayer d'inclure ça dans un script un
peu mieux fait (et peut être de l'inclure dans *teuse*, un bot irc en
perl).

J'ai noté que certains modules perl permettaient de *parser*
"facilement" des fichiers **ics**. En utilisant par exemple
``Data::ICal``, on peut envisager une base comme ça :

.. code-block:: perl

    use LWP::Simple;
    use Data::ICal;

    my $url = ""; # mettez l'url là
    my $raw_data = get($url);
    my $parsed_data = Data::ICal->new(data => $raw_data);

    # utilisation des données...

Voilà donc pour les quelques possibilités que j'explorerais peut être
plus en détail un peu plus tard ;)

A la prochaine !

.. _ADE Campus: http://fr.adesoft.com/ress.php?id_c=26&id_rubrique1=27>`_
