================
OpenData au Mans
================

:date: 2015-01-04 11:28:41
:slug: opendata-au-mans
:authors: matael
:summary: Quelques conseils pour que ça devienne utilisable
:tags: opendata, LeMans, imported

L'autre soir (et ce n'est pas une première), j'ai voulu voir ce qu'on pouvait tirer des données ouvertes par l'agglomération
du Mans. Cette envie est revenue après avoir vu que GitHub_ proposait désormais de présenter tous les fichiers GeoJSON_
sous forme de carte, directement `dans leur interface`_.

J'ai vu dans cette nouveauté une occasion de faire mes armes sur le GeoJSON (que je ne connais que peu) et de visualiser
par la même occasion ces fameuses données pour proposer d'éventuelles améliorations à la communauté.

Autant vous le dire tout de suite, ce but n'est **pas** atteint, ... et a peu de chance de l'être dans l'état actuel.

Je vais dans la suite formuler une série de propositions pour rendre ces données utiles, mais avant, laissez moi vous
rappeler quelque chose : *une donnée qui ne circule pas est une donnée morte*. Citons (une fois n'est pas coutume) les
précepte du DataLove_ :

    Love data

    Data is essential

    Data must flow

    Data must be used

    Data is neither good nor bad

    There is no illegal data

    Data is free

    Data can not be owned

    No man, machine or system shall interrupt the flow of data

    Locking data is a crime against datanity

    Love data

Nous ne reviendrons pas sur les implications de tels préceptes, mais gardez bien en tête les lignes 1, 2, 3, 4 et 10.

Proposition 1 & 2 : Conventions de Nommage & d'Arborescence
-----------------------------------------------------------

Si on souhaite permettre le traitement de ces données de manière efficace, il faut absolument que les simples noms des
fichiers ne soient pas une entrave au traitement.

Un nom de fichier **ne doit pas comporter d'espace ni d'accents** (il doit passer l'expression régulière ``/^[\w-\.]+$/`` ).
C'est une règle. Ça évite les conditions et les pré-traitements à rallonge dans les scripts et ça évite les caractères non-standards.

Vous n'êtes surement pas sans savoir qu'au sein d'un même dossier (disons répertoire), on ne peut avoir deux fichiers
ou répertoires portant le même nom. Deux jeux de données dont les dossiers partagent le même nom (par exemple *csv/* pour
*Les bureaux de vote* et *Les secteurs de bureaux de vote*), c'est à éviter à tout prix.

Si on devait établir des règles de nommage ne chamboulant pas tout, je proposerais quelque chose du genre :::

    nom_du_jeu_type
    ├── nom_du_jeu.txt
    ├── nom_du_jeu.csv
    └── etc...

Avec :

- ``type`` le type de jeu (SHP, CSV, KMZ, etc...)
- le ``csv`` peut être n'importe quel fichier de données
- le ``txt`` contient les métadonnées (nous y reviendrons)

Si par contre on peut tout chambouler, alors il faudrait envisager qu'une URL donne accès à un et un seul fichier, non
*zippé* directement utilisable par un script. Quitte à avoir un JSON ou un YAML rassemblant métadonnées, liste des
URLs et sommes de contrôle associées.

Le plus important étant tout de même que **tous les jeux partagent une arborescence commune et fixe d'une mise à jour
sur l'autre**.


Proposition 3 : Site dédié et communauté
----------------------------------------

Plutôt que d'intégrer les données au site existant, je propose la création d'un site dédié à ça, avec une liste de
diffusion mail au moins pour que les utilisateurs des données puissent discuter.

Pourquoi ? En tant que codeur, devoir aller sur un site comme ça pour récupérer les données me fait mal :

- Les URLs ne me permettent pas de scripter quoique ce soit (qu'est ce que c'est que cet ``uuid`` dans les paramètre GET ?) ;
- Si je fais une liste de ces UUID, rien ne prouve qu'ils ne changeront pas ;
- Les données ne sont pas facilement récupérables (encore des UUID...).

Bref, ça me fait peur et ne me donne pas envie de les utiliser. Pas du tout.

De ce côté là, il faut savoir qu'il y a une chose que les développeurs aiment, connaissent et savent utiliser : les API.

API signifie *Application Programming Interface*, c'est une interface de programmation qui, ici, permettrait un accès
scriptable aux données.

Vous n'arriverez pas à me faire croire que les données mises en ligne sont utilisées par des personnes lambda dans leur
vie de tous les jours. L'OpenData a deux cas d'utilisation majeurs :

- soit les données sont brutes et seront principalement utilisées par les développeurs pour la création d'applications
  les utilisant (dans ce cas, le fournisseur propose une API) ;
- soit les données sont traitées et mises en forme pour être utilisées par le grand public, et à ce moment là, le
  fournisseur propose un site de consultation des données tout-en-un.

Madame Michu n'installera pas un mapper GIS pour lire les données sur les pistes cyclables avant sa sortie vélo du mardi
après-midi : soit vous lui donnez un moyen de voir les données, soit vous laissez les autres le faire sans leur mettre
des bâtons dans les roues.

La proposition est donc la suivante : mettre en place un site rassemblant :

- une présentation du projet OpenData au Mans et ses principaux acteurs
- une documentation pour l'API d'accès
- un moyen de s'inscrire pour obtenir des clés d'API (et ne pas avoir à revalider la license à chaque fois)
- l'API elle même avec des *endpoints* bien foutus
- une mailing-list ou un forum, bref, un espace de discussion et d'interaction entre développeurs et agents de la ville
  de sorte à faciliter la création d'une communauté.

Ce dernier point est particulièrement important et ne requiert pas énormément de travail.
Evitez à tout prix le simple formulaire de contact.

Pour la partie documentation regardez comment faire sur ReadTheDocs_ où demandez à ceux qui savent. Une documentation est
**très** importante.

Proposition 4 : Mise à jour des données
---------------------------------------

Certains jeux de données actuellement proposés n'ont pas été mis à jour et plusieurs personnes m'ont rapporté que
certains comprenaient des erreurs.

Cela nous mène à la quatrième proposition : les jeux très statiques doivent être marqués comme tels et clairement
identifiés, de plus, il faut fournir un moyen de vérifier facilement si le jeu a changé depuis la dernier vérification
(une somme SHA-1 pourrait le faire). Si on veut que les jeux soit utilisés, il faut que les développeurs puissent
vérifier les mise à jour des jeux statiques facilement, sans forcément télécharger le jeu.

Un autre moyen est présenté avec la proposition 5.

Les jeux les plus fréquements mis à jour doivent aussi être clairement signalés. Leur mise à jour ne doit pas casser la
compatibilité sauf si c'est **clairement annoncé** et **à l'avance**.

Enfin, donnez la possiblité aux utilisateurs de rapporter les erreurs (voire de les corriger, cf proposition 6) ; et ce
de manière simple.

Proposition 5 : Metadonnées
---------------------------

Si les données sont importantes, leur contexte l'est tout autant.

Dans ce fameux site rassemblant les jeux, proposez une page par jeu rappelant les métadonnées de ce jeu. Actuellement
elles sont dans un fichier texte dans le zip du jeu, or, on ne veut télécharger que la charge utile, pas les méta
données. Si vous souhaitez à tout prix les proposer au téléchargement, faites un fichier JSON ou YAML supplémentaires
recensant les métadonnées et faites en sorte que ce fichier ait toujours la même organisation ; de sorte que l'ensemble
des fichiers de métadonnées forme aussi un jeu de données.

Dans ces métadonnées, un champ pourrait être réservé au *timestamp* de la dernière mise à jour, permettant ainsi de
retrouver facilement les jeux nouveaux.

L'autre point important serait de répertorier les différents fichiers d'un même jeu ainsi que leur somme de controle.

Proposition 6 : Open-Source
---------------------------

L'accès libre, c'est beau. Mais ce qu'il y a de mieux encore, c'est de permettre à tous de participer à l'amélioration à
la fois des données et du site de la communauté.

Des outils existent pour ça (je ne citerais que GitHub_) et permettent de proposer un moyen à tous d'améliorer l'outil
fourni.

Enfin, de nombreuses personnes pourraient être intéressées pour bosser sur un projet comme celui-ci, pourquoi ne pas
leur en donner la possibilité ?


Conclusion
==========

Voilà donc 6 premières propositions, j'encourage tous les lecteurs de ce billet à en proposer d'autres en commentaire,
que j'ajouterai à la suite.

Il s'agit là d'une simple réflexion sur comment rendre vraiment utiles les jeux proposés actuellement, fédérer une
communauté autour de l'OpenData et permettre au plus grand nombre d'utiliser ces données.
Ce billet n'a d'autre prétention que de vouloir faire réfléchir un peu sur cette question qui s'avère de plus en plus
importante.

Aujourd'hui, nous n'avons que parlé de propositions sur l'organisation de l'accès aux données. Avant de se lancer dans
quoique ce soit, je pense qu'il serait très important de réunir les acteurs de l'OpenData ainsi que ses utilisateurs
(développeurs, etc...). Il faudra bien sûr discuter aussi de l'infrastructure technique et des details d'accessibilité
des données, mais le chemin n'est peut être pas si long qu'il n'y parait...

**PS: Merci aux gens du HAUM et de #haum pour les remarques et la relecture :)**


.. _GitHub: https://github.com
.. _GeoJSON: http://en.wikipedia.org/wiki/GeoJSON
.. _dans leur interface: https://github.com/blog/1528-there-s-a-map-for-that
.. _DataLove: http://datalove.me/
.. _ReadTheDocs: https://readthedocs.org/
