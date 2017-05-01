============================
Scripts et Auto-modification
============================

:date: 2015-01-04 11:28:39
:category: imported
:slug: scripts-et-auto-modification
:authors: matael
:summary: Quand un script s'ajoute des lignes
:tags: scripts, lol, tips

J'ai récemment eu besoin qu'un de mes script s'ajoute des données (une variable en fait).

Voilà donc un article (court, **très** court même) pour vous montrer la tête que ça a :

.. sourcecode:: bash

    #!/bin/bash

    if [[ $secret ]]; then
        echo $secret;
    else
        touch strange2
        echo "#!/bin/bash" >> strange2
        echo "secret='this is secret'" >> strange2
        tail -n +2 $0 >> strange2
        chmod +x strange2
        mv strange2 $0 && exit
    fi

Regardons le code de plus près :

1. le script vérifie si la variable ``$secret`` est définie et l'affiche si c'est le cas
2. sinon :

   a. il crée un fichier ``strange2``
   b. colle le she-bang dans ce fichier
   c. y écrit la définition de la variable ``$secret``
   d. se recopie lui même (à partir de la deuxième ligne: ``-n +2``) dans ce fichier
   e. rend son clone éxécutable (il aurait été mieux de faire en sorte de lui assigner les mêmes droits que l'original)
   f. change le nom du clone par son propre nom (contenu dans ``$0``) et quitte


Si on teste le script :::

    $ cat strange.sh
    #!/bin/bash

    if [[ $secret ]]; then
        echo $secret;
    else
        touch strange2
        echo "#!/bin/bash" >> strange2
        echo "secret='this is secret'" >> strange2
        tail -n +2 $0 >> strange2
        chmod +x strange2
        mv strange2 $0 && exit
    fi
    $ ./strange.sh
    $ cat strange.sh
    #!/bin/bash
    secret='this is secret'

    if [[ $secret ]]; then
        echo $secret;
    else
        touch strange2
        echo "#!/bin/bash" >> strange2
        echo "secret='this is secret'" >> strange2
        tail -n +2 $0 >> strange2
        chmod +x strange2
        mv strange2 $0 && exit
    fi
    $ ./strange.sh
    this is secret


... on remarque qu'il s'est bien modifié et qu'au deuxième lancement, il affiche bel et bien de contenu de la variable
ajoutée.

Voilà donc un *truc* pas forcément très très utile, mais rigolo.
