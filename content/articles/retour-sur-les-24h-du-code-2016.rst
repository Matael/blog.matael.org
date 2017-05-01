===============================
Retour sur les 24h du Code 2016
===============================

:date: 2016-02-11 17:29:30
:slug: retour-sur-les-24h-du-code-2016
:authors: matael
:summary: Point de vue d'un organisateur sur 24h de RTFM
:tags: code, perso, haum, imported

Le weekend du 23 & 24 janvier se tenait la 5ème édition des 24h du Code.

Organisées par la `Ruche Numérique`_ et l'ENSIM_ dans les (très classieux) locaux de la CCI, les 24h du Code 2016 ont
rassemblé 109 participants venant de Sarthe mais aussi de Mayenne ou de Normandie !

Les sujets
==========

Comme ça a été le cas les 2 dernières années, 4 sujets étaient proposés :

Lazer! Majer!
  Un *puzzle game* entièrement à développer, avec des LASER, des miroirs, des prismes, etc...

Roméo, médecin malgré lui !
  Réaliser un outil de visualisation de pièces de théatre, mise en scène à l'appui, en s'appuyant sur un fichier RTF.

Minions
  Comment contrôler des Minions à base de servomoteurs & et de capteurs ultrasons. Proposé par `ST Micro`_, le sujet
  utilisait des cartes électroniques arduino et SPC5. Il nécessitait aussi de disposer d'un système sous MS Windows 7 ou
  plus... dommage.

OpenData
  Utiliser les bases des données de `Sarthe Dev`_ sur les lieux et évènements touristiques pour une visualisation atypique.
  Le sujet était écrit par le HAUM, nous étions donc présents sur toutes les 24h pour assister équipes et organisateurs.

Le déroulement
==============

Là encore, peu de nouveautés sur ce plan. Après une arrivée vers 9h du matin, samedi, les participants se voient
présenter les sujets dans la foulée. À 10h30, le code commence pour les plus précoces, il faudra attendre 11h pour que
tout le monde s'y mette.

Après une bonne heure de planning et de discussions, les premières lignes commencent à couler. La répartition des sujets
a été assez tranchée : beaucoup d'équipes sur Lazer! Majer!, 5 ou 6 sur Roméo, 4 équipes sur l'OpenData et le reste sur
les Minions.

Comme à l'accoutumée, le repas du midi est l'occasion de discuter entres équipes et pour les organisateurs celle de
prendre la température. Les participants avaient l'air satisfaits des sujets et plutôt confiants. Que de bonnes
nouvelles !

L'après midi et le début de soirée est toujours un moment intéressant : le code coule à flot, les pistes les plus
farfelues sont explorées, écartées... C'est le moment où discuter avec les équipes est le plus intéressant : toutes
proposent des solutions techniques très bien lèchées avec un plan d'action à 6 ou 7h...

Après `Agile Mans`_, un évènement autour des méthodes Agile auquel j'ai pu assister peu de temps auparavant, le point
problèmatique me saute aux yeux : très peu d'équipes travaillent de manière itérative... aucune ne fait d'intégration
continue.

Le repas du soir se passe et arrive le début de nuit... l'occasion pour nous de faire le point avec les équipes OpenData
et de leur fixer un objectif à cours terme : afficher les données pour qu'on puisse vérifier qu'ils ont bien compris.
L'occasion aussi d'aller boire un coup avec 3 de nos équipes pour discuter et se détendre un peu.

Alors que la nuit étend ses heures, nous continuons à jouer avec un *proof of concept* en QML développé au HAUM_ et qui
répond partiellement à notre sujet.

Après un grand nombre de parties de babyfoot et une course de chaises, il est l'heure du casse-croûte. Une nuit blanche,
c'est long... c'est aussi éprouvant et, souvent, les non-initiés oublient un peu qu'il faut manger dans la nuit pour
tenir. Passer dans les salles des 24h vers 4h du matin, c'est l'assurance de voir mines défaites devant le code qui
marche pas et nausées (faussement associées au manque de sommeil). *A contrario*, passer dans les salles avec une
corbeille de fruits et la promesse de lasagnes pour les plus décalqués, c'est apporter soulagement et bonheur.

Suite à cette tournée frugivore-*oriented*, il est 5h et nous passons voir nos équipes pour leur rappeller que le début
de notation se fera après le petit-déjeuner.

La fin du concours se passe finalement sans encombre ni problèmes et à 11h, les résultats sont annoncés :

- **Dharma initiative** vainqueurs sur le sujet Roméo, Médecin malgré lui
- **Les codeurs de l'infini** vainqueurs sur le sujet Minions
- **<include lama.h>** vainqueurs sur le sujet Lazer! Majer!
- **MatelasB** vainqueurs sur le sujet OpenData
- **MixITeam** vainqueur sur le prix spécial pros

En plus de ça, deux "prix d'honneur" ont été remis aux équipes de lycéens **["String"] = malloc(u)** & **IfsWeCaen**.

Le sujet Opendata
=================

Le sujet OpenData (dont le texte est `téléchargeable ici`_) traitait de restitution de données récupérées sur l'API de
`Sarthe Dev`_.

Les objectifs fixés permettait de guider les candidats et de s'assurer que les fonctions de base seraient présentes à la
fin :

#) Exploiter les données ouvertes de la base de données touristiques de Sarthe Développement.
#) Afficher simplement les données collectées.
#) Concevoir et implémenter une interface atypique pour interagir avec les données (par exemple dans un navigateur web).
#) Intégrer des données soumises par les utilisateurs, et éventuellement (**Bonus**) récoltées depuis d’autres sources.
#) **Bonus** Explorer au moins un autre canal pour accéder aux données (application, PDF thématiques, écran connecté, etc...)

Les participants avaient à leur disposition une `documentation écrite par le HAUM`_ ainsi que toutes les ressources
qu'ils voulaient sur OData (modules, bibliothèques, doc, etc...).

Les Équipes OpenData et leurs réalisations
==========================================

Quatre équipes avaient choisi de travailler sur le sujet OpenData.

MixITeam
--------

L'équipe issue du GIE Sésame Vitale travaillait en Java.

Ils ont développé une interface web assez claire avec possibilité de naviguer dans les évènements (rien de
particulièrement atypique de ce côté là).

La grosse surprise les concernant venait de la deuxième interface qu'ils ont eu le temps d'implémenter : un contrôle
vocal d'une appli permettant de chercher dans les évènements.

Ebahis devant cette performance qu'ils nous ont cachée pendant 24h, nous leur avons attribué le Prix Entreprise.

Codix
-----

La jeune équipe du CESI nous a proposé très tôt une bonne manière de présenter les données. Leur idée reposait sur
l'utilisation d'un graphique sous d3.js représentant les catégories en une suite de bulles concentriques.

Le travail de l'équipe s'articulait donc autour d'un serveur PHP/MySQL d'une part pour récupèrer et stocker les données
avant de les restituer sur une interface web (HTML/CSS/JS).

Ils ont pris à bras le corps le dernier objectif (bonus) et nous ont proposé un panel de 4 représentations... seul
inconvénient : les représentations n'étaient pas complètement fonctionnelles et les choix techniques mis en oeuvre ne
prenaient pas en compte la durée de vie (courte) des données.

MatelasB
--------

L'équipe était formée de 3 étudiants acousticiens de l'ENSIM_. Le code n'est pas leur domaine et ils ont choisit de
travailler avec le seul outil qu'ils maîtrisaient : MATLab_.

Pour ceux qui ne connaissent pas, MATLab est un outil de calcul matriciel développé par MathWorks largement utilisé dans
le monde scientifique.

Malgré cet énorme handicap (MatLab ne dispose pas de *parser* JSON ou XML par exemple), ils sont venus à bout de la
récupération de données, de leur enregistrement et organisation, de leur affichage (non sans mal) et de la prise en
compte d'entrée utilisateur. Enfin, ils ont trouvé une solution pour générer un PDF (récupérant du même coup le bonus
sur la deuxième restitution) !
Il ne manquait alors que la prise en compte de sources tierces pour répondre à tout le sujet.

Ils ont perdu des points avec un mauvais choix technique et une excuse non valable (non, *«je ne connais que ça»* n'est
pas valable) mais ont été constants sur tout le reste.

Nous leur avons accordé la victoire sur le sujet (hors pros).

The DuckTypers
--------------

Les DuckTypers était un groupe de bio-informaticiens arrivés (en retard) de Rennes dont les membres ont décidé de
travailler en Python3.

Ils réussi l'exploit de casser une de leurs distros Linux dès le début et un des participants a passé 24h à coder en ssh
sur le PC de son voisin... Ils ne partaient donc pas gagnants malgré un excellent *background* technique...

Il a fallu les pousser aux fesses pour qu'ils nous présentent les données récupérées et leur rendu final comportait
simplement un ... bouton rouge dans une page web.

Un appui sur ledit bouton lançait une récupération des coordonnées GPS et allait chercher en base de données les
évènements géographiquement proches. Leur appli utilisait aussi un système météo pour affiner les résultats et une base
externe pour les enrichir.

La suite des 24h
================

Les 24h se sont, vous l'aurez compris, plutôt bien déroulées. Les équipes sont restées très concentrées toute la nuit
et les rendus (sur notre sujet comme sur les autres) ont été assez impressionnants.

Mon impression est que, année après année, les 24h du Code attirent de plus en plus de personnes venant de plus en plus
loin et surtout avec un niveau de plus en plus haut.

L'écriture des sujets est toujours un moment très particulier puisqu'on se demande comment il sera analysé et perçu par
les équipes. Cette année, nous manquions un peu d'idées nous avons donc choisi de proposer un sujet qui pourrait nous
servir. Je m'explique.

Le HAUM_ a, depuis quelques mois maintenant, envie de créer un agenda libre participatif des évènements sur Le Mans et
la Sarthe. Le travail effectué en amont des 24h et celui des équipes au cours des 24h (surtout au niveau des interfaces
utilisateur) est un bon tremplin pour mener à bien ce vieux projet.

Nous verrons, dans les prochaines semaines, comment s'oriente nos actions, mais ce qui est sûr c'est que nous sommes fiers
des rendus et heureux d'avoir à nouveau participé !

.. _Ruche Numérique : http://www.laruchenumerique.com/
.. _ENSIM : http://ensim.univ-lemans.fr/
.. _ST Micro : http://www.st.com/
.. _Sarthe Dev : http://www.sarthe-developpement.com/
.. _Agile Mans : http://www.agile-mans.org/
.. _téléchargeable ici : /static/images/24hc16/subject.pdf
.. _documentation écrite par le HAUM : http://24hc16.haum.org/
.. _MATLab : http://fr.mathworks.com/products/matlab/
.. _HAUM: http://haum.org
