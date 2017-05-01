=======================================
Cyber-Ouvre-Boite : Opendata... ou pas.
=======================================

:date: 2015-01-04 11:28:42
:slug: cyber-ouvre-boite-opendata-ou-pas
:authors: matael
:summary: Hacker un service pour une interface
:tags: setram, LeMans, python, haum, opendata, imported

Voilà plusieurs mois, au cours d'un Jeudi du Libre (rencontres organisées à l'Epicerie du Pré par LinuxMaine autour du
LL et de l'écosystème qui l'entoure), nous avions discuté de la déplorable absence d'API pour les horaires de la SETRAM.

En bons bidouilleurs assoiffés de hack et dans un élan de datalove, nous nous étions souvenus de la présence d'un
service (appelé Timéo) permettant d'obtenir les heures des prochains passages de bus/tram à partir d'un code noté dans
l'arrêt. La bière avait ensuite coulé et la diiscussion en était restée là.

Aujourd'hui, par un superbe matin de pluie, je me suis dit qu'il était temps de creuser un peu le sujet.

Premier rendez vous sur setram.fr_. En bas, à peu près au milieu, l'objet du hack : un widget Timéo (widget qui semble
un peu buggé d'ailleurs... mais passons).
Je teste le bazar avec un code au pif et je me retrouve sur `cette page`_ et, regardant un peu le code source je vois ça
:

.. code-block:: html

    <IFRAME src="http://dev.actigraph.fr/actipages/setram/pivk/acti.php?a=recherche_arret&arret=Université" width=680 height=500 scrolling=auto frameborder=0 allowtransparency="true" > </IFRAME>

Certes, l'utilisation d'iframe pourrait être motif de pendaison, mais ce n'est pas l'objet aujourd'hui. Par contre l'URL
est intéressante. Si on essaye de l'ouvrir dans un navigateur (sans les arguments ``GET``), on est redirigé vers cette
`URL ci`_.

Beaucoup plus intéressant déjà... en plus, le code source est nettement plus bavard et on peut y voir ceci :

.. code-block:: html

    <form id='form_ligne' class='form' action='relais.html.php' method='post'>
        <input type='hidden' name='a' value='recherche_ligne' />
        <span class='input' style='width:100%;'><span><em><select id='ligne_sens' name='ligne_sens'>
            <option value=''>S&eacute;lectionnez une ligne</option>
            <option value='2_A'>Ligne 2 > GALLIERE</option>
            <option value='2_R'>Ligne 2 > BEAUREGARD</option>
            <option value='3_A'>Ligne 3 > OASIS</option>
            <option value='3_R'>Ligne 3 > GAZONFIER</option>
            <option value='4_A'>Ligne 4 > LA PAIX</option>
            <option value='4_R'>Ligne 4 > SAINT GEORGES - ST JOSEPH</option>
            <option value='5_A'>Ligne 5 > ARNAGE</option>
            <option value='5_R'>Ligne 5 > GARE ROUTIERE</option>
            <option value='6_A'>Ligne 6 > SAINT MARTIN</option>
            <option value='6_R'>Ligne 6 > LAFAYETTE</option>
            <option value='7_A'>Ligne 7 > RAINERIES</option>
            <option value='7_R'>Ligne 7 > SAINT MARTIN</option>
            <option value='8_A'>Ligne 8 > LES HALLES</option>
            <option value='8_R'>Ligne 8 > PARC MANCEAU</option>
            <option value='9_A'>Ligne 9 > ZAMENHOF</option>
            <option value='9_R'>Ligne 9 > COMTES DU MAINE</option>
            <option value='11_A'>Ligne 11 > CLOSERIE</option>
            <option value='11_R'>Ligne 11 > LE CADRAN - SAINT AUBIN</option>
            <option value='12_A'>Ligne 12 > SAINT MARTIN</option>
            <option value='12_R'>Ligne 12 > REPUBLIQUE</option>
            <option value='16_A'>Ligne 16 > ALLONNES</option>
            <option value='16_R'>Ligne 16 > GARES</option>
            <option value='17_A'>Ligne 17 > OASIS</option>
            <option value='17_R'>Ligne 17 > CIMETIERE DE L'OUEST</option>
            <option value='18_A'>Ligne 18 > ROUILLON</option>
            <option value='18_R'>Ligne 18 > SAINT-AUBIN</option>
            <option value='19_A'>Ligne 19 > GUETTELOUP</option>
            <option value='19_R'>Ligne 19 > LA PAIX</option>
            <option value='20_A'>Ligne 20 > EPERON</option>
            <option value='20_R'>Ligne 20 > AIGN&Eacute;</option>
            <option value='21_A'>Ligne 21 > ARNAGE</option>
            <option value='21_R'>Ligne 21 > SAINT MARTIN</option>
            <option value='22_A'>Ligne 22 > COMTES DU MAINE</option>
            <option value='22_R'>Ligne 22 > SARGE</option>
            <option value='23_A'>Ligne 23 > YVRE L'EVEQUE</option>
            <option value='23_R'>Ligne 23 > REPUBLIQUE</option>
            <option value='24_A'>Ligne 24 > MULSANNE</option>
            <option value='24_R'>Ligne 24 > RUAUDIN</option>
            <option value='25_A'>Ligne 25 > CHAMPAGN&Eacute;</option>
            <option value='25_R'>Ligne 25 > R&Eacute;PUBLIQUE</option>
            <option value='26_A'>Ligne 26 > ALLONNES</option>
            <option value='26_R'>Ligne 26 > SAINT GEORGES - SAINT JOSEPH</option>
            <option value='33_A'>Ligne 33 > COMTES DU MAINE</option>
            <option value='33_R'>Ligne 33 > BELLEVUE</option>
            <option value='T1_A'>Ligne T1 > UNIVERSITE</option>
            <option value='T1_R'>Ligne T1 > ESPAL - ANTARES MMArena</option>
        </select>
        </em></span></span>
    </form>

Ce formulaire appelle donc la même page que celle qui l'a affiché. Les options contiennent les lignes assorties de leur
sens (dans les *values* il est noté ``A`` ou ``R`` pour le sens).

Cool....

Voyons ce qui se passe si on entre une valeur et qu'on  regarde la requête (c'est du ``POST``, il faudra regarder les
headers). Voilà les valeurs du formulaire posté si on sélectionnne la dernière ligne de la liste ::

    a: recherche_ligne
    ligne_sens: T1_R

Pas trop compliqué... On arrive alors sur une autre page qui contient un autre champ ``select`` encore plus bavard :

.. code-block:: html

    <form id='form_arrets' class='form' action='relais.html.php' method='post'>
        <input type='hidden' name='a'     value='recherche_arrets'/>
        <input type='hidden' name='refs'  value='271747608'/>
        <input type='hidden' name='code'  value='802'/>
        <input type='hidden' name='sens'  value='R'/>
        <input type='hidden' name='ligne' value='T1'/>
        <span class='input' style='width:100%;'><span><em>
        <select onchange="new Timeo().parseValue(this.value);" class='combobox' id='list_refs' name='list_refs'>
            <option value='271747608_802' selected='selected'>ANTARES MMArena (802)</option>
            <option value='271747859_852'>ATLANT.-SABLONS (852)</option>
            <option value='271747844|271747588_842'>CADRAN-EPINE (842)</option>
            <option value='271747842|271747586_846'>CAMPUS-RIBAY (846)</option>
            <option value='271747858_850'>CHURCHILL (850)</option>
            <option value='271747603_812'>DURAND-VAILLANT (812)</option>
            <option value='271747861_856'>EPAU-G.BERNISSON (856)</option>
            <option value='271747849|271747593_832'>EPERON (832)</option>
            <option value='271747862_858'>ESPAL (858)</option>
            <option value='271747847|271747591_836'>GAMBETTA-MURIERS (836)</option>
            <option value='271747853|271747597_824'>GARES (824)</option>
            <option value='271747605_808'>GLONNIERES (808)</option>
            <option value='271747604_810'>GOYA (810)</option>
            <option value='271747607_804'>GUETTELOUP (804)</option>
            <option value='271747843|271747587_844'>HAUTE VENELLE (844)</option>
            <option value='271747845|271747589_840'>HOPITAL (840)</option>
            <option value='271747860_854'>ILE AUX SPORTS (854)</option>
            <option value='271747856|271747600_818'>JAURES-PAVILLON (818)</option>
            <option value='271747606_806'>JULES RAIMU (806)</option>
            <option value='271747848|271747592_834'>LAFAYETTE (834)</option>
            <option value='271747852|271747596_826'>LECLERC-FLEURUS (826)</option>
            <option value='271747602_814'>PONTLIEUE (814)</option>
            <option value='271747851|271747595_828'>PREFECTURE (828)</option>
            <option value='271747850|271747594_830'>REPUBLIQUE (830)</option>
            <option value='271747857|271747601_816'>SAINT MARTIN (816)</option>
            <option value='271747846|271747590_838'>THEODORE MONOD (838)</option>
            <option value='271747841|271747585_848'>UNIVERSITE (848)</option>
            <option value='271747855|271747599_820'>VIADUCS (820)</option>
            <option value='271747854|271747598_822'>ZOLA (822)</option>
        </select>
        </em></span></span>
    </form>

Là, c'est plus compliqué. Les 5 premiers champs sont plus où moins identifiables :

- application demandée (ici, recherche des arrêts)
- référence (probablement un identifiant unique à la ressource demandée)
- code de l'arrêt terminus
- sens de circulation
- ligne

Arrive ensuite une liste d'arrêts dans ce sens assortis de leur numéro Timéo et d'une valeur qui ressemble à une
référence couplée à l'ID Timéo. Je ne sais pas comment elle sont calculée, mais en envoyant la bonne référence, on peut
demander n'importe quel arrêt et les prochains passage de bus/tram. Essayons d'en sélectionner un pour voir...

On tombe sur une page où des éléments sont affichés mais où le code source ne contient que des appels Ajax (ici en
cliquant sur l'arrêt Espal) :

.. code-block:: javascript

    <script type="text/javascript">
	document.getElementById('consultation').innerHTML = '<br /><i>Veuillez patienter ...<i>';
	var http = new Ajax('consultation','relais.html.php');
	http.Periodic(60);
	http.POST('a=refresh\x26refs=271747862\x26ran=143268141');
    </script>

On note que les paramètres de la ``POST`` ne sont plus que 3 ::

    a:refresh
    refs:271747862
    ran:814240342

Il nous faudra parser ça pour récupérer le tout. La ref se retrouve via la page d'avant, le ``a`` ne bouge pas, mais
``ran`` semble important.

Bon... ben on a tout. C'est parti pour du code :)

Code !
======

Un petit module pour commencer :

.. code-block:: python

    import requests
    import re
    from bs4 import BeautifulSoup as BS

    class Timeo:
        """ Interface entre Python et le service Timéo de la SETRAM """

        pass

On aura en effet besoin de ``BeautifulSoup`` pour le parsing de l'HTML, de ``re`` pour l'extraction de données des
champs de texte et de ``requests`` parce que l'``urllib`` python est dégueulasse.

Un petit constructeur ?

Alons y :

.. code-block:: python

    def __init__(self,
        URL="http://dev.actigraph.fr/actipages/setram/module/mobile/pivk/relais.html.php"):

        self.URL = URL

        self.session = requests.Session()

        # session init
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.57 Safari/537.36',
            'Content-type': 'application/x-www-form-urlencoded'})
        self.session.get(URL)

        # regexs
        self.extr_name_code = re.compile("([^\(]+) \((\d+)\)")
        self.extr_code = re.compile("\((\d+)\)")

Je laisse l'URL paramétrable,... au cas où. La session permettra de retenir les cookies (automatiquement dans
``requests``, tout comme le *header* ``Keep-Alive``).

On prend aussi le temps de modifier l'``User-Agent`` pour être sûr que l'API ne nous mette pas à la porte et le
``Content-type`` parce que ça mange pas de pain que ça nous permet d'être au plus proche des *headers* qu'envoyait le
navigateur.

Je défini aussi deux regexes (que je vous laisse le soin de déchiffrer) qui nous serviront plus tard.

Liste des arrêts
----------------

Je pense qu'un bon début serait de récupérer la liste des arrêts pour un couple ligne/sens donné.
Je laisse la possibilité à la fonction d'extraire un attribut plutot que le nom de l'arrêt (la ``value`` par exemple
pour récupérer les refs, vous vous souvenez ?) :


.. code-block:: python

    def getall_arrets(self, lignesens, attr_to_extract="name"):
        """ Récupére les informations sur tous les arrêts d'une même ligne dans
        un sens de circulation donné (A ou R, voir API SETRAM... ahem.).

        lignesens : ligne à parser et sens de circulation (ex: 8_R , T1_A, ...)
        attr_to_extract : paramètre à extraire (par défaut : nom de l'arrêt)

        """

        # on prépare le "formulaire"
        POST_params_liste = {
           'a': 'recherche_ligne',
           'ligne_sens': lignesens
        }

        # on balance la requête et on parse le retour pour récupérer les options
        result = self.session.post(self.URL, POST_params_liste)
        options = BS(result.text).find_all('option')

        # on reconstruit ensuite un dico à partir des options contenant soit :
        # - le code -> le nom de l'arrêt
        # - le coode -> un attribut
        if attr_to_extract == "name":
            return dict([self.extr_name_code.search(_.text).group(1,2)[::-1]
                         for _ in options])
        else:
            return {self.extr_code.search(_.text).group(1):_.get(attr_to_extract)
                    for _ in options}


Explication
~~~~~~~~~~~

Je vais expliquer ces deux lignes de ``return``.

Pour la première, on identifie le pattern de ListComprehension :

.. code-block:: python

    [<truc> for _ in options]

Regardons ce que fait <truc> :

.. code-block:: python

    self.extr_name_code.search(_.text).group(1,2)[::-1]

Alors... ``self.extr_name_code`` c'est une instance de ``re.RegexObject`` qu'on a défini dans le constructeur. On
appelle la méthode ``search()`` et lui passant le texte à parser en argument. On récupère alors les groupes matché via
la méthode ``group()`` et on inverse le tuple via ``t[::-1]`` (celle là, je l'expliquerais pas, allez revoir la doc sur
le slicing).

Finalement, on a une liste de tuples que l'on passe à la fonction ``dict()`` qui en fait un dictionnaire.

Pour la deuxième maintenant, plus de ListComprehension mais directement un DictComprehension :

.. code-block:: python

    {cle:valeur for truc in bidule}

Ici, bidule c'est notre liste d'options, truc, c'est la variable _ qui représente une option (avec ses attributs et son
text). Pour la clé on fait passer la regex ``self.extr_code`` du début qui récupère le code de l'arrêt depuis ``_.text``
et pour la valeur, on récupère la valeur de l'attribut ``attr_to_extract`` passé en paramètre à la fonction.

Voilà donc une fonction capable de nous récupérer une hashtable liant un code au nom de l'arrêt ou à un attribut lié à
ce code.

Récupération des numéros de lignes
----------------------------------

Problème, il nous faut connaitre le numéro et le sens de la ligne pour utiliser la fonction précédente. On va donc les
récupérer depuis la première page (après l'iframe) :

.. code-block:: python

    def get_lignes(self):
        """ Récupère une hashtable entre les lignes (et leur direction)
            et le code de ligne correspondant

        """

        return {
            _.text:_.get('value') for _ in
            BS(self.session.get(self.URL).text).find_all('option')
            if _.text.find('>') > -1
        }

Pas d'argument pour cette fonction. Elle récupère le code HTML de la page pointée par ``self.URL``, le parse et cherche
toutes les options. Elle itère alors sur cette liste d'options en excluant toutes celle qui ne contiennent pas de ``>``.
Pourquoi cela ? parce que la seule option n'en contenant pas contient : *"Sélectionnez une ligne"*, ce qui ne nous
intéresse pas. Finalement on construit le dico avec comme clé le nom de la ligne et comme valeur la *value* de l'option
correspondante. Cette *value* contient en effet le code de la ligne (numéro et sens).

Informations sur un arrêt
-------------------------

C'est la dernière partie. Etant donnés un code de ligne/sens et un code Timéo d'arrêt, on cherche à récupérer les
prochains horaires de passage.


.. code-block:: python

    def get_arret(self, lignesens, code):
        """ Récupère les prochains passages à un arret donné

        lignesens : code de ligne (ligne+sens, voir get_ligne())
        code : code timéo de l'arret
        """

        # on sépare le paramètre lignesens en utilisant un tuple unpacking
        ligne,sens = lignesens.split('_')
        # on s'assure que le code est bien une str
        code = str(code)

        # récupération des références
        # souvenez vous celles ci sont importantes, peuvent être complexes
        # et surtout ne sont pas recalculable (en tout cas, on ne sait pas
        # le faire) on utilise donc la première méthode écrite pour récupérer
        # la liste des codes et la reférence associée
        refs_all = self.getall_arrets(lignesens, attr_to_extract='value')

        # on crée le dico pour le post en respectant le format
        # répéré dans les headers tout à l'heure
        POST_params = {
            'a': 'recherche_arrets',
            'refs': refs_all[code].split('_')[0], # les références récupérées sont suivies
                                                  # d'un _ puis du code de l'arrêt. On
                                                  # splite pour ne garde que la ref
            'code': code,
            'sens': sens,
            'ligne': ligne,
            'list_refs': refs_all[code]
        }

        # On envoie ce formulaire et on récupère le
        # paramètre ran dans la requuete Ajax de la page suivante.
            res = self.session.post(self.URL, data=POST_params)
        ran = re.search(
            "ran=(\d+)",
            BS(res.text).find_all('script')[-1].text.splitlines()[-2]
            ).group(1)
        # Explication :
        # BS(res.text).find_all('script') : parsing du HTML et récupération
        #                                       de la liste des balises script
        # [-1].text                       : on a besoin que du texte du
        #                                       dernier script
        # .splitlines()[-2]               : on splite le texte du script à
        #                                       chaque \n et on garde l'avant
        #                                       dernière ligne (celle avec la requête)
        # On passe le tout au search par regex et on récupère
        # le groupe matché qui correspond à la valeur de ran


        # on prépare le formulaire suivant
        POST_params2 = {
            'a' : 'refresh',
            'refs': POST_params['refs'],
            'ran' : ran
        }

        # on l'envoie pour récupérer la page avec des vraies données.
        res = self.session.post(self.URL, data=POST_params2)
        # les stops sont les contenus des li où sont notés les temps (le premier ne
        # nous sert pas, d'où le [:1]
        stops = [_.text for _ in BS(res.text).find_all('li')[1:]]

        # liste des heures d'arrêt finale
        stoptimes = []

        for i in stops:
            # si on trouve le mot "imminent" ou "en cours", on ajoute
            # "maintenant" à la liste
            if i.find('imminent') > -1 or i.find('en cours') > -1:
                stoptimes.append("maintenant")
            else:
                # sinon, on a soit un nombre de minutes sous la forme "XX minutes"
                next = re.search("(\d+ minutes?)", i)
                if not next:
                    # soit une heure "XX H XX"
                    next = re.search("(\d+ H \d+)", i)

                # quoiqu'il en soit, on prend ce qu'on trouve
                stoptimes.append(next.group(1))

        # et on renvoie la liste.
        return stoptimes


Ça nous fait un gros module bien velu parce que le site sur lequel on cherche les données n'a pas été prévu pour ça. Si
l'ergonomie du site est pas trop mal pour un humain, c'est une plaie pour un programme. Mais bon... bref. On l'a eu :)

Pour le code complet, `c'est ici`_ !

Exemple d'utilisation
=====================

Le code suivant affichera d'abord la liste des lignes et le code leur étant associé, puis la liste des arrêts pour la
ligne de tram vers Espal/Antares et enfin le temps avant le prochain passage d'un tram à chaque arrêt (dans la direction
Espal/Antares) :

.. code-block:: python

    # on instancie l'interface
    t = Timeo()

    print("Liste des lignes et des codes associés :")
    liste = t.get_lignes()
    for k,v in liste.items():
        print(k+' -> '+v)

    print("\n")
    print("Liste des arrêts et de leur code pour la ligne T1_R :")
    arrets = t.getall_arrets('T1_R')
    for k,v in arrets.items():
        print(k+' -> '+v)

    print("\n")
    print("Temps avant l'arrivé du prochain tram pour les arrêts de T1_R :")
    for k,v in arrets.items():
        print("Arrivé à l'arret "+v+" : "+t.get_arret('T1_R', k)[0])


Conclusion
==========

Je ne prétends pas avoir fait un travail parfait. L'idéal serait clairement une API prévue pour ça. Je dis simplement
qu'en peu de temps on peu récupérer des données utilisables. Et que si un peu de temps avait été consacré par les
"propriétaires" des données, ce serait franchement plus simple.

Ces données sont des données de mobilité intéressant potentiellement un très grand nombre de personnes et qui ont **tout
à gagner** à être ouvertes. Devoir parser du HTML *a la mano* pour récupérer des horaires de tram, c'est une aberration
à l'heure où tout le monde parle d'OpenData.

Si le courage me prends, je mettrais en ligne une API permettant d'utiliser facilement les données ainsi parsées à
partir de simple requêtes HTTP. Ce n'est pas mon job, mais aujourd'hui, il y a une certaine demande vis à vis de l'accès
à ces données.

A bon entendeur


.. _setram.fr: http://setram.fr
.. _cette page: http://setram.fr/698-TIMEO2C-l-info-en-temps-reel.html
.. _URL ci: http://dev.actigraph.fr/actipages/setram/pivk/relais.html.php
.. _c'est ici: https://gist.github.com/Matael/6742478
