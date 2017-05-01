============================
Diffusion de mail sous Linux
============================

:date: 2015-01-04 11:28:39
:slug: diffusion-de-mail-sous-linux
:authors: matael
:summary: Envoyer le même mail à une liste de destinataires sous linux
:tags: scripts, mail, tips, imported

La plupart du temps, lorsqu'on envoie un mail à une série de destinataires, on préfère que chacun ne voit pas la liste
des autres destinataires.

Ici, ce n'était pas le point le plus important sachant que chacun avait déjà les adresses de tous les autres, mais par
contre, la liste d'adresse étant contenue dans un fichier, il me semblait plus *"clean"* de scripter la chose.

Au commencement, une liste, un message
======================================

Admettons que j'ai besoin de diffuser l'adresse d'un nouveau site à toute une série de personnes.

Je vais rédiger un mail dans un fichier texte (appellons le ``message.txt``) :::

    Ahoy !!

    Tu as vu le nouveau site de chats ?

    http://superschats.org

    Alors ?

    matael

*PS : je ne sais pas si ce site existe hein ! Je rédige ce billet dans le train ;)*

Ensuite, il me faut un fichier (``adresses.txt``) contenant la liste des destinataires, un par ligne :::

    geek@aww.org
    youpi@example.com
    punka@chat.net

Nous avons donc deux fichiers, il nous en faut un 3ème : le script.

Ensuite, le script
==================

Il suffit de savoir utiliser ``for`` et ``mail`` et on arrive à ça :

.. code-block:: bash

    #!/bin/bash

    sujet=":3"

    for i in  $( < adresses.txt); do
        mail -s "$sujet" "$i" < message.txt && echo "Message envoyé à $i"
    done

On lance ensuite le script comme d'hab et voilà le résultat :::

    $ chmod u+x script.sh
    $ ./script.sh
    Message envoyé à geek@aww.org
    Message envoyé à youpi@example.com
    Message envoyé à punka@chat.net

Voilà une astuce qui paye pas de mine mais qui peut parfois s'avèrer bien utile...

**EDIT :**

J'ai reçu une mention sur twitter de la part de **@sylvain_soliman** :

    It would be safer to quote "$i" in the mail line, and more efficient to replace the cat subprocess by an inline $(< adresses.txt)

J'ai modifié le script en conséquence. Ce sont en effet deux bonnes pratiques, même si pour le ``$i`` il y a peu de
chance d'avoir un soucis dans ce cas précis.
