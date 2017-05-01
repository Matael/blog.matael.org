==============================
Cyber-Ouvre-Boite : Le concept
==============================

:date: 2015-01-04 11:28:42
:slug: cyber-ouvre-boite-la-concept
:authors: matael
:summary: Pour quoi faire ?
:tags: setram, LeMans, opendata, haum, imported

.

  Ce post est un complément à `cet article`_. Il explique la démarche, les raisons qui m'ont poussé à réalisé le petit
  hack présenté dans l'autre article.

Je pense que, dans le cadre de ce bout de code, la démarche sous-tendant le projet a au moins, sinon plus, de valeur que
le code lui-même. Je m'explique.

L'opendata est un sujet qui me tient beaucoup à coeur et je pense que ce sera un élément central dans les prochaines
mutations de notre société. Aujourd'hui, l'opendata, beaucoup en parlent, certains la comprennent, mais peu la mettent en
oeuvre.

Pourquoi la SETRAM ?
====================

Pourquoi avoir choisi de mettre au jour les données de la SETRAM plutot que de quelqu'un d'autre ? Après tout, j'aurais
pu faire ça avec les emplois du temps de la fac...

La SETRAM était le "client" parfait pour ce hack. Les données existent et sont librement accessibles. Elles ne sont pas
facilement visibles, mais suffisament pour éviter les problèmes. De plus, je sais que des discussions ont déjà eut lieu
concernant l'ouverture des données de mobilité dans l'Ouest. Je sais aussi que la SETRAM n'est pas en tête de file des
soutiens à l'OpenData (comprenez soutiens *effectifs*).

Je cherche dans ce projet à montrer quelque chose de simple : une donnée qui ne circule pas, qui n'est pas (ou trop peu)
utilisée, est une donnée morte. Si elle n'est utile à personne, elle n'a pas de raison d'être. Or, aujourd'hui, il y a
une demande pour un accès simple aux donnnées de mobilité. Une demande qui pourrait aboutir à une création de valeur
et de richesse qui bénéficierait à la communauté urbaine.

L'opendata n'est pas un simple enjeu sociétal, c'est un facteur économique important qui est trop souvent négligé.

C'est pour ça que je trouvais important de casser ce thème de la protection des données publiques et de fournir une API
partielle vers les données de mobilité sur Le Mans.

Pourquoi tout publier ?
=======================

Ceux qui auront lu les 10 premières lignes du fichier_ contenant le code auront noté une license un peu particulière :
la WTFPL (Do What The Fuck You Want Public License).

Cette license est une marque supplémentaire de l'ouverture de la démarche : je tiens à ce que tout un chacun puisse
réutiliser ce code (dans un but commercial ou non, bienveillant ou non). Je tiens encore plus à une chose, c'est que les
gens qui cherchent à comprendre le principe du code puisse le faire. Je veux que le code, les données et la démarche
soient les plus libres et disponibles possibles pour être facilement transposés.

Il est important de montrer aux gens que franchir le pas d'écrire soi-même les outils qui manquent n'est pas si
compliqué : je ne suis ni informaticien, ni magicien ni gourou et pourtant....
Il faut simplement se bouger un peu et aller fouiller jusqu'a trouver une prise. Il faut juste essayer de faire
comprendre autour de soit que ces données sont utiles.

Le but ultime !
===============

Le but ultime de ce projet est simple : je voulais juste montrer que c'était possible. Que l'accès à des données de
manière automatisée était possible et pouvait d'ores et déjà servir certains développeurs. Si moi, de l'extérieur,
j'arrive à un projet utilisable alors de l'intérieur on peut faire quelque chose de vraiment extra !

Quelle suite à ce projet ?
==========================

J'espère de tout coeur que ce petit *proof of concept* fera réfléchir (c'est sa raison d'être). J'espère voir sous peu
fleurir une API[#]_ officielle et complète. J'espère vraiment que la SETRAM et toutes les autres organisations
concernées travailleront avec ceux qui sont susceptibles d'utiliser lesdites données.

Voilà aussi un problème énorme à l'ouverture des données : pour que le résultat soit bon, il faut que l'ouverture se
fasse de concert avec les utilisateurs futurs du service. Ouvrir des données pour en ouvrir ne sert à rien (j'en ai
déjà parlé sur ce blog) ; il faut que cette ouverture s'inscrive dans un projet, dans une dynamique complète.

Rêvons une seconde : le jour où les données seront vraiment ouvertes, ne serez vous pas content de regarder le matin sur
votre ordinateur ou votre téléphone s'il reste des places de parking et sinon combien de temps vous allez mettre pour
vous rendre au boulot en transports en commun ? N'aimeriez vous pas que votre téléphone vous suggère *en live* le chemin
le plus rapide d'un point A à un point B en prenant en compte toutes les options (voiture, tram, bus, vélo, marche,
skateboard et compagnie...) ?

Tout cela n'est pas si compliqué (pour le skateboard peut être....), mais avant tout, il nous faut de la matière sur
laquelle travailler : il nous faut des données. Des données bien ouvertes et facile d'accès.

Je ferais sous peu une API perso pour pallier ce manque. Je ne promets pas d'être un excellent mainteneur mais je compte
prouver que si les organisations responsables ne le font pas alors les développeurs le feront eux mêmes.

À ceux que ça intéresse, je suis tout disposé à causer ouverture de données autour d'un cafe/d'une bière/d'un coin de
table et ce avec qui que ce soit. Et sachez que je ne suis pas le seul. (Et d'ailleurs, jeudi prochain, c'est Jeudi du
Libre à l'Epicerie du Pré).

.. [#] Interface de programmation

.. _cet article: /writing/cyber-ouvre-boite-opendata-ou-pas/
.. _fichier: https://gist.github.com/Matael/6742478
