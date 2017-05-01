==========================
Retour sur les 24h du code
==========================

:date: 2015-01-04 11:28:40
:category: imported
:slug: retour-sur-les-24h-du-code
:authors: matael
:summary: Comment aurait on pu mieux faire ?
:tags: perso, fac, python

Le week-end dernier (du vendredi 14h au samedi 14h), j'ai participé avec 3 autres gars aux `24h du Code`_.
Je vais ici essayer de faire une petite synthèse du déroulement de l'épreuve pour savoir ce qui est à améliorer pour une
eventuelle participation future.

Pour bien comprendre de quoi il s'agit, les **24h du code** est un concours informatique organisé par l'ENSIM.
Le week-end dernier se tenait la deuxième édition de ce concours.

Finalement, mes comparses pour le challenge seront nommés L, T et E (je leur ai pas demandé s'ils acceptaient que leur
nom soit ici donc...).

Le lieu/l'épreuve
=================

On est arrivés avant 14h et on a commencé à s'installer avant la distribution des sujets.
La présentation s'est tenue de 14h à 14h15 dans l'amphi de l'ENSIM où les organisateurs sont revenus sur plusieurs
points :

- le droit à l'image (commençons par les bassesses administratives)
- le déroulement de l'épreuve en elle même et particulièrement de la nuit
- les modalités de notation pour la fin (applaudimètre après sélection ici)
- les sujets !

Le lieu
-------

On avait à notre disposition plusieurs salles de l'ENSIM, dont la cafet' (détente/manger !) et un amphi (repos).

Il faut aussi préciser que le café était *"à volonté"* (je cite).

Les sujets
----------

Il y avait 3 sujets, chaque équipe devait en choisir un et aller le plus loin possible :

- Tapping Game (jeu façon GuitarHero où un joueur appuie sur des touches au bon moment pour simuler une guitare)
- RPG Old School
- Résolveur de Puzzle

Le dernier sujet était de loin le plus dur. La seule donnée étant une image contenant les différentes pièces qu'il
fallait alors trouver, découper, retourner puis assembler. Deux équipes seulement ont décidé de se faire vraiment mal et
il faut avouer qu'ils s'en sont plutôt bien tirés !

De notre côté, on a choisi le second sujet et il faut avouer que c'était pas glorieux glorieux...
En définitive, au bout d'un peu moins de 24h on avait :

- un moteur de jeu modulable complet (ajout d'objets/monstres via des fichiers JSON)
- une gestion automatique des combats
- une génération aléatoire des cartes (un peu trop imprévisible à mon gout, mais bon)
- un début d'interface graphique

On aurait pu aller plus loin, voici comment.

Aller plus loin
===============


On va essayer de regrouper les bilans et les améliorations possibles :


- équipe
- gestion du temps/des tâches
- gestion de la nuit
- sujet lui même
- oh putain il neige !


Equipe
------

Du côté de l'équipe, l'entente était bonne. Le seul point vraiment à redire (et qui était pourtant un peu crucial),
c'est que certains (la moitié en fait) ne connaissaient pas ou peu le langage...

En fait, on avait depuis longtemps arrêté la décision du langage (Python) que chacun devait apprendre/travailler pour être
capable de faire le challenge sans trop de soucis.

Finalement, je me dis que j'ai bien fait d'emprunter un exemplaire de *Apprendre à programmer en python3* à la BU...

Sans ce handicap non négligeable, on aurait pu coder plus sereinement, et surement aller plus loin.

Gestion du temps/des tâches
---------------------------

De ce côté pas trop de problèmes : la gestion des tâches était pas trop mal même si 2 pour l'IHM auraient pas été de
trop : L a abattu un joli boulot de ce côté là. On a choisi pygame_ pour l'IHM parce qu'il nous a semblé le plus adapté,
mais il a fallu l'apprendre sur le tas.

En regard de ça, un peu de temps passé sur la *lib* avant nous aurait fait gagner pas mal de temps et là aussi nous
aurait permis d'avancer un peu plus vite...

Tant pis !

A noter que pas mal de code a été produit ce jour là et que la répartition n'était pas franchement équitable et ce
serait peut être à revoir pour une prochaine fois.

Une belle *checklist* aurait aussi évité les *"Bon, ben, il reste quoi ?"* au petit matin...


Gestion de la nuit
------------------

Pour de meilleures conditions, il aurait fallu que tout le monde aille dormir au moins un peu : E et T ne l'ont pas fait
et effectivement, on code moins vite crevé.

En fait, je pense que la recette miracle c'est :

#. code
#. 1h de dodo
#. 20min de reveil/casse-croute post-roupillon
#. retour au code

Et la durée du temps de code dépend du codeur : c'est lui qui se connait le mieux.

Ne pas (beaucoup) manger pendant la nuit nous a aussi fait tourner la tête un peu. Bref, les casse-dalles sont
**obligatoires** pour un hackathon réussi.

Sujet lui même
--------------

En dépit de ce qui était noté sur le sujet, on a voulu partir sur trop de fronts en même temps et on s'est faits avoir
comme des bleus.

En fait, on s'est lancés dans l'idée que le moteur de jeu ne serait pas long à développer (du moins en v1) et qu'on
aurait le temps de faire de l'affichage ensuite. Même si la majorité du code tournait sans soucis, si on a aucun moyen
de tester et de montrer le résultat à la fin, on est pas sélectionnés (et c'est ce qui c'est passé).

C'est là que ça a pêché surtout. On aurait dû partir sur une vue console et des *maps* plus simples d'abord avant de faire
de la génération aléatoire de *maps*, mais tant pis.

Oh putain il neige !
--------------------

Ben ouais, ce soir là, il neigeait. Et après coup, je me dis que ça aurait pu faire une détente bénéfique à tous
(presqu'autant que le babyfoot du bas ;)).


Voilà ce que je retiens de cette épreuve. C'était sympa, mais certains truc peuvent être améliorés, de notre côté ou du
côté de l'organisation.

Pour le côté organisation :

- les salles/couloirs étaient froids, ce n'est pas agréable à 3h du mat'
- pourquoi ne pas avoir fait qu'une grande salle avec une ambiance tech ? ça aurait rajouté une touche sympa
- ce serait top de trouver un moyen de favoriser la discussion entre les groupes : qu'on ne vienne pas que pour coder
  mais aussi pour rencontrer des codeurs
- encourager les profs à participer serait marrant aussi, sortir un peu du cadre scolaire

Bref, ça reste une bonne expérience. A refaire !

.. _pygame: http://www.pygame.org/news.html
.. _24h du Code: http://les24hducode.univ-lemans.fr/
