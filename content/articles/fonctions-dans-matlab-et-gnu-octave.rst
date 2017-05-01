===================================
Fonctions dans MATLab et GNU Octave
===================================

:date: 2015-01-04 11:28:42
:slug: fonctions-dans-matlab-et-gnu-octave
:authors: matael
:summary: Quelques astuces bien utiles...
:tags: octave, fac, imported

.

    Tout d'abord, sachez que MATLab est une marque déposée de Mathworks. Ensuite, sachez que dans la suite, Octave sera
    mis pour GNU/Octave. Enfin, sachez que n'en déplaise à certains pour la majorité des tâches courante Octave fait très
    bien son affaire et que pour le reste (calcul formel et compagnie), la logique veut qu'on choisisse un outil plus
    adapté. Un seul logiciel qui remplit plein de fonctions ne mérite pas d'attention : mieux vaut plein de logiciels
    qui ne font qu'une chose mais qui la font bien. Le libriste a parlé.

Voilà un article assez court pour parler des fonctions dans Matlab et Octave. Il y aura (bien sûr) du code et les
différences entre les deux logiciels seront notées si elles existent.

Différence principale : le paradigme du fichier-fonction
========================================================

C'est bien là une énorme (et bien gênante) différence entre Matlab et Octave. Dans le logiciel commercial, les
fonctions doivent être écrites dans un fichier nommé comme la fonction et qui n'en contiendra qu'une.

Sous Octave, pour que les fonctions puissent être utilisés dans plusieurs scripts, il faudra aussi qu'elles soient écrites
seules dans un fichier qui porte leur nom, toutefois, pour des fonctions internes aux scripts, il est possible de les
écrire dans le fichier directement. Ce script compilera sous Octave et affichera la liste des nombres de 1 à 11:

.. code-block:: matlab

    clear all;
    close all;

    function res = plus_un(x)
        res = x+1;
    end

    for i=0:10
        disp(plus_un(i));
    end

Par extension, dans Octave il est possible de définir des fonctions dans le prompt (la fenêtre de commande) mais pas
dans Matlab.

Problème de ce paradigme
------------------------

Si à première vue, il est plutôt bénéfique de forcer la création d'un fichier par fonction, il faut savoir que ça a
tendance à déplaire aux programmeurs.

En effet, certains scripts sont plus simples si certaines parties sont déportées en fonctions. Les fonctions ainsi créées
peuvent êtres utiles au script qui les définit mais ne servir à rien ailleurs : il n'y a alors aucune raison de leur dédier
un fichier complet et elles aurait leur place au plus près du code les utilisant.

Syntaxe d'un fichier-fonction
=============================

La syntaxe d'une fonction est la même dans Matlab et Octave ::

    function [<valeurs de retour>] = <nom de la fonction>(<liste d'arguments>)
        % <docstring en commentaire>

        <corps où chacune des valeurs de retour est définie au moins une fois>

    end

Vous noterez l'absence de ``return``, en effet, c'est la valeur que contient la variable qui est retournée.
Vous remarquerez aussi que les valeurs de retour sont dans un tableau : c'est le moyen de renvoyer
plusieurs valeur en fin de fonction.

Les arguments sont par défaut tous optionnels : la fonction ``nargin()`` à l'intérieur d'une fonction permet de savoir
combien ont été passés lors de l'appel et donc d'adapter le comportement au besoin (d'autres méthodes existent).

La doctring, elle, permet de documenter l'effet de la fonction.

Enfin, sachez que quasiment tout est optionnel dans cette syntaxe. Ces fonctions sont valides (du moins dans octave) :

.. code-block:: matlab

    function say_yop
        disp('yop');
    end

    fonction say_num(num)
        disp(num1str(num));
    end

Passage de fonction en argument
===============================

Il est possible de passer des fonctions en tant qu'arguments d'autres fonctions.
Par exemple, je définis le fichier ``plot_func.m`` :

.. code-block:: matlab

    function plot_func(f, interval)
        % f est une fonction
        % interval un tableau [x0, x1]

        x = (interval(1):0.05:interval(2));
        y = zeros(length(x));
        for i=(1:length(x))
            y(i) = f(x(i));
        end

        plot(x,y)
    end

(Oui, elle fonctionne).

Dans un second fichier (disons ``ma_fonc.m``) :

.. code-block:: matlab

    function y = f(x)
        y = x^3+x-1;
    end

Et taper ce qui suit dans le prompt affichera la courbe :math:`y = x^3+x-1, \forall x\in[0,1]` :

.. code-block:: matlab

    plot_func(@ma_fonc, [0,1]);

Vous noterez (et c'est là tout l'objet de cette section) l'ajout d'un ``@`` devant le nom de la fonction à passer en
paramètre. Si ``ma_fonc`` est une fonction, ``@ma_fonc`` est un *function handle* : un objet qui représente une
fonction et qui peut être appellé comme une fonction.

Fonctions anonymes : là où commence le lol
==========================================

Les développeurs de Matlab ne sont pas complètement fous et ont ajouté une fonction intéressante (bien évidement
présente dans Octave) : les **fonctions anonymes**.

Regardez ce code :

.. code-block:: matlab

    f = @(x) x^3+x-1;

    f(2) % 9

Cet objet bizarre **est** une fonction. Et il ressemble étonnamment à sa notation mathématique : :math:`f : x \mapsto
x^3+x-1`.

La syntaxe est simple ::

    <nom> = @(<arg list>) <valeur de retour>

On peut donc créer à la volée ces fonctions anonymes (on parle de fonctions *lambda* aussi) et ce dans le prompt ou dans
un fichier dans Matlab et Octave.

Bien sûr, si ça marche pour un ça marche pour deux arguments :

.. code-block:: matlab

    addition = @(x,y) x+y;

    addition(1,2); % 3

Cool non ?

Bien sûr, on peut aussi passer des fonctions :

.. code-block:: matlab

    h = 0.0001; % c'est arbitraire

    f = @(x) x^3+x-1;
    diff = @(f, x) (f(x+h)-f(x))/h; % une définition un peu crade de la dérivée


A noter : pour passer une fonction anonyme en paramètre à une fonction il n'y a **pas besoin de mettre un ``@``**.

    *Explication (un peu technique) :*
    Lorsque l'on ajoute un ``@`` devant un nom de fonction, on crée un *function-handle* ou plus précisément une
    référence vers cette fonction (un peu comme un pointeur). Cette référence est automatiquement déréférencée par
    l'utilisation de parenthèse ce qui fait qu'appeller la référence comme une fonction revient à appeler la fonction.
    Quand on crée une fonction anonyme, on doit l'associer à une variable en faite, dans ``f = @(x) x^3+x-1`` il y a
    deux choses : la création d'une fonction (``@(x) x^3+x-1``) et la création d'une référence pointant vers cette
    fonction d'une part et l'affectation de cette référence à la variable ``f`` d'autre part.

Exemple 1 : Dérivée
-------------------


Ci-dessus, ``diff(f,x0)`` calcule une approximation du nombre dérivé de :math:`f` en :math:`x_0`.
La définition propre d'une dérivé est la suivante :

.. math::

    f'(x) = \lim_{h\to0} \frac{f(x+h)-f(x)}{h}

On peut l'approximer ainsi (pour :math:`|\Delta x| << 1`) :

.. math::

    f'(x) = \frac{f(x+\Delta x)-f(x)}{\Delta x}

On a alors la possibilité d'écrire une fonction qui renvoie la fonction dérivée de toute fonction passée en paramètre :

.. code-block:: matlab

    h = 0.0001; % c'est arbitraire
    derive = @(f) ( @(x) (f(x+h)-f(x))/h )

Et pour l'appel :

.. code-block:: matlab

    f = @(x) x^3+x-1;
    f2 = derive(f);

La fonction ``derive`` pourrait être exprimée ainsi :

.. math::

    derive : f \mapsto f'

C'est donc une fonction qui prend en paramètre une fonction et qui renvoie une fonction. Je vous avais prévenu, c'est
puissant.

Exemple 2 : partial()
---------------------

Certains langages disposent de la fonction ``partial`` qui prend une fonction de plusieurs variables et une liste
d'arguments à fixer et qui renvoie une fonction de une ou plusieurs variables (mais moins qu'avant) en ayant fixé une
partie des arguments. Par exemple, pour une fonction de 2 variables :

.. math::

    partial : f(x, y), (x=a) \mapsto f(x=a, y)


Ce genre de fonction n'existe pas dans Matlab ou Octave de base, mais on peut les écrire facilement :

.. code-block:: matlab

    f = @(x,y) x+y;
    partial = @(f,a) ( @(y) f(a,y));

    plus_un = partial(f,1);

On commence par créer une fonction de x et y qui calcule x+y. On définit ensuite une fonction ``partial`` qui a f et a
associe une fonction :math:`y \mapsto f(a,y)`. Enfin, on utilise ``partial`` et ``f`` pour écrire la fonction
``plus_un`` qui ajoute 1 a un nombre passé en paramètre (dans le jargon des langages de programmation, cela s'appelle du
*currying*).


Conclusion
==========

Même si la syntaxe est pas forcément très agréable, les fonctions dans Matlab et Octave sont relativement puissantes.

L'utilisation de fonctions anonymes permet de rendre le code plus lisible et plus facilement réutilisable. De plus avec
un peu d'habitude, ce genre de programmation est plus simple et beaucoup plus rapide à mettre en œuvre.

Enfin, ces fonctions anonymes permettent de combler certains manques du langage (currying, closures, décorateurs, etc...)
et rendent la programmation sous Matlab et octave légèrement plus agréable (ça ne vaut toujours pas un C, un Python ou
un Haskell, mais c'est mieux que rien :)).

