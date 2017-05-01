===========================
Meilleur Dev de France 2013
===========================

:date: 2015-01-04 11:28:42
:slug: meilleur-dev-de-france-2013
:authors: matael
:summary: Retour d'expérience
:tags: perso, RucheNumérique, imported

Jeudi 10 Novembre, un peu avant 18h, 12 Bd Charles Nicolle.

C'est parti pour le concours Meilleur Dev de France 2013. On y va a trois, sans autre ambition que de passer une bonne
soirée. Ce genre de concours de programmation est souvent dominé par quelques (très) bons, et aucun de nous n'avait le
niveau pour prétendre à la gagne (rien ne coûte de la jouer hein, mais il ne faut pas y placer tous ses espoirs...).

Après deux bonnes heures de route, nous voilà arrivés sur le périph', on enchaîne (sur une bonne idée de Fabien) vers
Bercy pour y prendre le métro qui nous mènera porte de Clichy, à 30 mètres de l'école 42.

L'école
=======

Sur la route du retour, j'ai résumé cette école à "un hangar avec des plateaux, des tables et des macs dessus". Je pense
ne pas être trop loin de la vérité. L'école est assez asseptisée. Plusieurs (3) salles machines entièrement équipées
d'iMacs en forment le point central, une salle en sous-sol permet d'accueillir d'éventuels évènements (pas trop grands...) et le hall est spacieux sans plus. A noter le cube transparent en face de la porte d'entrée qui, pris entre 4 piliers, renferme 4 baies serveurs (loin d'être pleines) le tout baignant dans une lumière bleue.

Bon, sol gris foncé nu, plafond minimaliste, grilles sur les piliers dans les salles machines, on sent que toute la déco
provient des machines elles-mêmes et que l'école est bâtie autour de celles ci. L'absence complète de tableau (façon
salle de cours) m'a un peu étonné, mais après tout, on a surement pas tout vu...

L'arrivée et l'installation
===========================

L'arrivée s'est faite un peu en catastrophe peu avant 20h30. Le concours a été décal à 20h45, mais en attendant pas
question de se tourner les pouces : il n'y a que des macs, avec un clavier QWERTY Mac.... Après plus de 10 minutes,
j'arrive enfin à activer un AZERTY qui semble fonctionner, à ceci près que la ponctuation n'est pas entièrement à sa
place : une belle saloperie pour coder...

Autre point très négatif : l'évaluation du code se fait via un éditeur en ligne. Celui ci n'étant pas forcément très
ergonomique, on nous propose d'utiliser un IDE/éditeur en local puis de copier-coller vers le formulaire en ligne...
Pas de Vim préconfiguré ni de temps pour rapatrier les dotfiles ce sera donc un Eclipse.... Il est 45, le concours
commence.

Le Concours
===========

Les langages, les conditions
----------------------------

Les développeurs avaient le choix entre C#, PHP et Java. C'est assez limité. Je me suis rabattu sur PHP (ne connaissant
pas C# et n'aimant pas Java...). Le vainqueur codait en Java pour sa part, comme (apparemment) une assez vaste majorité des participants.

Si l'organisation avait laissé entendre que les questions ne porteraient pas sur les spécificités des langages, elles
étaient loin de porter sur de l'algo pure et les énoncés étaient parfois un peu biaisés...


C'est parti !
-------------

A la fin de leur décompte oral pour l'ouverture du concours, tout le monde a dû tenter de se logger en même temps, et on a attendu
une grosse minute avant l'affichage des instructions... Puis une autre avant l'affichage de la première question...

On nous indique qu'il est possible d'écrire dans une console de sortie visible sur l'interface en ligne (en PHP via ``local_print_r`` et
``local_echo``) : à entendre les grognements derrière moi, ça ne marchait pas super bien pour tout le monde... (ou bien
il n'avait rien compris).

La première question portait sur l'écriture d'une classe d'itérateur permettant de *mergemr* plusieurs itérateurs en un
seul. Il nous était demandé d'écrire les méthodes ``next()`` et ``hasNext()`` pour cette classe.

La méthode ``next()`` devait renvoyer le plus petit élément des ``n`` Tickers reçus et lever une
``NoSuchElementException`` s'il n'y en avait plus. La méthode ``hasNext()`` devait, elle, permettre de vérifier s'il
restait un ou plusieurs éléments sans lever d'exception.

J'ai d'abord essayé de *dumper* tous les itérateurs dans un ``array()``, trier l'``array()`` et renvoyer les éléments un a un.
J'ai écopé d'un magnifique dépassement de la capacité mémoire (découvrant du même coup qu'on était limités).

Je me suis donc rabattu, après 20 minutes dans la doc PHP concernant l'OOP (que j'avais complètement oublié, depuis 4
ans...), vers l'écriture du constructeur (première méthode appelée lors de la création d'un objet à partir d'une classe)
pour dumper le premier élément de chaque ticker et une ``next()`` qui va
chercher le minimum du tableau de dump et qui remplace l'élément par le suivant dans le ticker lié.

On aurait gaspillé moins de temps si la consigne avait indiqué que le constructeur était à écrire pour récupérer les
tickers, que les tickers envoyés au constructeur étaient eux même triés, etc...

Bref, une question assez mal posée et au total (entre les problèmes liés à la disposition des touches, aux lenteurs du
site, aux quelques erreurs et à cette saloperie de constructeur) 45 minutes de perdues...

La question 2 était un FizzBuzz inversé : on nous donnait une chaine contenant une liste de nombre séparés par des
espaces où les multiples de n, et les multiples de p avaient été remplacés par Buzz. A nous d'écrire la fonction
permettant de retrouver les entiers p et n (sachant que : ``p > n > 0`` et ``p % n != 0``). Assez simple comme question,
une petite extraction des nombres remplacés, un crible et voilà :)

La question 3 nous donnait une liste de point "ABCDA" par exemple et il s'agissait de vérifier si aucun des chemins
n'avait été emprunté 2 fois. J'ai trouvé le dernier bug au moment du gong final (et très probablement sur une évaluation
favorable) : je n'ai pas eu le temps de passer la question 4 ensuite...

La remise des prix et la DevParty
=================================

    "A la DevParty, les devs étaient partis", F. Saujot

La remise des prix s'est faite sans grande ambiance (oui, un peu quand même, mais rien de glorieux) quant à la DevParty,
il semblerait que beaucoup s'en soit allés avant qu'elle commence.

Il faut simplement savoir que personne n'a répondu aux 11 questions posées et que le premier n'est pas allé au-delà de la
huitième (autour de moi en salle machine, aucun n'avait passé la question 2).

Les plus, les moins
===================

Les questions n'étaient ni ridiculement simples, ni ridiculement complexes. Somme toute, ça semblait plutôt équilibré.
Je regrette par contre que la première ait été aussi mal posée et en ait handicapé autant.

Je m'attendais pas du tout à devoir faire de la POO : pour un concours d'algorithmique, de simples fonctions auraient
suffit.

Je suis assez déçu qu'il n'y ait eu que 3 langages de proposés et parmi ces trois ni de C/C++ ni aucun langage de script
(Python, Ruby, Perl, etc...). Je sais qu'ils n'ont pas eu beaucoup de temps pour préparer l'épreuve en elle-même, mais
un peu plus de choix aurait été cool...

Enfin, ça manquait de "geekness" pour un concours de programmation... même si c'était médiatisé, j'aurais préféré que
ça parle d'abord aux codeurs et non aux médias.

Conclusion
==========

L'expérience était enrichissante et sans aucun doute à refaire, mais avant que cela devienne un concours reconnu il
faudra revoir une partie de l'organisation et l'ambiance du concours en lui-même... Il faudra aussi éviter les problèmes
techniques d'accès à la base de données, de lag dans la compilation/l'exécution et surtout, proposer des claviers
standards, ou au moins un moyen des les utiliser complètement.


*EDIT : Merci à Poumcala pour sa relecture attentive et ses corrections.*
