=====================
Décrivons le matériel
=====================

:date: 2015-01-04 11:20:58
:slug: decrivons-le-materiel
:authors: matael
:summary: 
:tags: VHDL, imported

Certains composants sont programmables... vous connaissez probablement
les microcontrôleurs (programmés en C, BASIC, etc...) mais il en existe
d'autres comme les FPGA utilisent un **HDL** pour leur programmation
comme **VHDL** ou **Verilog**. Regardons de plus près à quoi ressemble
le premier...

--------------
HDL ? Kézaco ?
--------------

Les **HDL** sont des langages de description matérielle (*Hardware
Description Language*). On remarque que 2 en particulier ressortent : le
**VHDL** et le **Verilog**. Le troll qui tourne autour de ces langages
est violent et presque comparable à celui entre Linux et Windows ou
Mac...

En fait, une phrase revient assez courament :

    Le VHDL a été créé par des electroniciens ne comprenant rien à
    l'informatique, il a donc dû être bidouillé un bon moment avant
    d'être utilisable.

    Le Verilog à été créé par des informaticiens qui ne comprenaient
    rien à l'électronique, il a donc dû être bidouillé un bon moment
    avant d'être utilisable.

Il ressort toutefois que les deux langages font grosso modo la même
chose et peuvent être utilisés pour les même tâches.

On notera que le **VHDL** est très utilisé en europe alors que le
**Verilog** est souvent préféré outre-Atlantique...

------------------------
Super ! Ça sert à quoi ?
------------------------

**VHDL** signifie *VHSIC (Very High Speed Integrated Circuit) Hardware
Description Language*) il s'agit donc d'un langage de description
matérielle.

|Un Xilinx Spartan|

Il permet de *décrire* des composants en termes d'entrées/sorties d'une
part et de comportement d'autre part.

Les composants peuvent ainsi être compilés et chargés dans des FPGA
(*Field Programmable Gate Array* : mer de portes logiques
programmables).

Ci-contre un FPGA *Xilinx Spartan* (une bonne référence en général)
(`source de la photo`_)

-------------------------
Un exemple , un exemple !
-------------------------

Nous allons voir un exemple de description d'un *multiplexeur 4 vers 1*
en VHDL. Un multiplexeur (ou *mux*) est un composant permettant de
regrouper les données de N entrées vers 1 sortie. Voilà le schéma
logique d'un mux 4 voies et sa table de vérité :

|Schéma logique|

~~~~~~~~~~~~~~
Description...
~~~~~~~~~~~~~~

********************
Première vue externe
********************

On peut représenter ce composant selon 2 vue externes différentes, voici
la première :

.. code-block:: vhdl

    entity MUX1 is
        port(E0, E1, E2, E3, SEL0, SEL1 : in bit;
            S : out bit);
    end MUX;

On donne donc le nom de la vue, en précisant que c'est une ``entity``.
On déclare ensuite ses I/O, ici :

-  E0, E1, E2, E3, SEL0, SEL1 : entrées logique (binaires)
-  S : Sortie logique

******************************
Vue Externe 1 : Architecture 1
******************************

Nous avons une vue du composant en termes d'I/O, mais aucune information
sur son comportement.

Nous allons pour cela décrire une ``architecture`` que nous allons
ensuite lier à la vue externe.

.. code-block:: vhdl

    architecture FLOT_MUX of MUX1 is
    begin
        S <= ((not SEL0) and (not SEL1) and E0) or
             ((not SEL0) and SEL1 and E1) or
             (SEL0 and not(SEL1) and E2) or
             (SEL0 and SEL1 and E3);
    end FLOT_MUX;

Cette architecture se base sur une logique purement combinatoire
répondant à l'équation tirée de la table de vérité :

.. code-block:: vhdl

    S = (/SEL0./SEL1.E0) + (/SEL0.SEL1.E1) + (SEL0./SEL1.E2) + (SEL0.SEL1.E3)

Dans cette architecture, les instructions sont concurrentes : elles
**s'exécutent en même temps**.

******************************
Vue Externe 2 : Architecture 2
******************************

Une même ``entity`` peut avoir plusieurs ``architecture`` différentes.

Il existe un moyen de définir un comportement **séquentiel** pour une
``entity`` en utilisant un **processus** (``process``).

Voilà une seconde architecture pour notre multiplexeur exploitant cette
possibilité :

.. code-block:: vhdl

    architecture COMPOR_MUX of MUX1 is
    begin
        process
        begin
            if ((SEL0 = '0') and (SEL1 = '0')) then
                S <= E0;
            elsif ((SEL0 = '0') and (SEL1 = '1')) then
                S <= E1;
            elsif ((SEL0 = '1') and (SEL1 = '0')) then
                S <= E2;
            elsif ((SEL0 = '1') and (SEL1 = '1')) then
                S <= E3;
            end if;
            wait on E0, E1, E2, E3, SEL0, SEL1;
        end process;
    end COMPOR_MUX;

L'instruction ``wait on E0, E1, E2, E3, SEL0, SEL1`` à la fin du
processus indique que le composant attend un changement sur une des
entrées nommées.

*Note :* On aurait pu aussi mettre un temps. Par exemple
``wait for 100 ms`` aurait produit une attente de 100ms à la fin du
process.

************************************************
Architecture 2 : utilisation de vecteurs de bits
************************************************

Un vecteur de bit n'est ni plus ni moins qu'un tableau de bits dont une
des dimensions est 1.

Si nous observons correctement, on remarque que l'on peut considérer
l'ensemble \`{SEL0, SEL1} comme un vecteur de longueur 2.

Nous pouvons donc avancer une autre vue externe pour le multiplexeur et
une architecture qui va bien en utilisant un processus et une structure
``case`` :

.. code-block:: vhdl

    entity MUX2 is
        port(E0, E1, E2, E3 : in bit;
            -- SEL est un vecteur de bit indexé de 1 à 0
            SEL : in bit_vector(1 downto 0);
            S : out bit);
    end MUX2;

    architecture COMPOR_MUX2 of MUX2 is
    begin
        process
        begin
            case SEL is
                when "00" => S <= E0; -- On recopie E0 dans S
                when "01" => S <= E1; -- On recopie E1 dans S
                when "10" => S <= E2; -- On recopie E2 dans S
                when "11" => S <= E3; -- On recopie E3 dans S
            end case;
            wait on SEL, E0, E1, E2, E3;
        end process;
    end COMPOR_MUX2;

Tout ce qui est situé après ``--`` et sur la même ligne est un
commentaire (les commentaires multilignes n'existent pas).

Nous avons donc 2 vue externes possible est 3 architectures valable pour
le même composant.

~~~~~~~~~~~~~~~~~~~~
Comment je vérifie ?
~~~~~~~~~~~~~~~~~~~~

Au niveau syntaxique et simulation, des outils comme **ghdl** sont
plutot utiles.

Pour une simple analyse, la commande est la suivante :

.. code-block:: vhdl

    $ ghdl -a fichier.vhdl

-------------------------------------
Le bonus : le compteur 8 bits en VHDL
-------------------------------------

A vous de voir si vous comprenez tout là-dedans :

.. code-block:: vhdl

    entity COUNTER is
        port(S : out bit_vector(7 downto 0));
    end COUNTER;

    architecture ARCH1 of COUNTER is
    begin
        process
            variable N : integer;
            variable P : integer;
        begin
            N := 0;
            while (true) loop
                while (N<256) loop
                    for P IN 0 to 7 loop
                        if (N - 2**P >= 0) then
                            S(P) <= '1';
                        else
                            S(P) <= '0';
                        end if;
                    end loop;
                    wait for 100 ms;
                    N := N + 1;
                end loop;
                N := 0;
            end loop;
        end process;
    end ARCH1;

----------
Conclusion
----------

Le VHDL permet aussi l'association de composants entre eux pour créer
des composants plus importants en les décrivant par partie (un
additionneur complet sur 1 bit par exemple est l'assemblage de 2 demi
additionneur et d'une porte OU).

Ce concept plus avancé fera surement l'objet d'un prochain article.

-----
Liens
-----

Quelques infos sur **Wikipedia**

- `(fr) VHDL`_
- `(en) VHDL`_

.. |Un Xilinx Spartan| image:: /images/VHDL/3.jpg
    :width: 600px
.. |Schéma logique| image:: /images/VHDL/logique.png
    :width: 600px
.. _source de la photo: http://bak1.beareyes.com.cn/2/lib/200510/16/20051016006_0.htm
.. _(fr) VHDL: http://fr.wikipedia.org/wiki/VHDL
.. _(en) VHDL: http://en.wikipedia.org/wiki/VHDL
