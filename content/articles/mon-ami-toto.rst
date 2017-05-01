============
Mon Ami toto
============

:date: 2015-01-04 11:20:57
:slug: mon-ami-toto
:authors: matael
:tags: legacy, imported
:summary: 


Laissez moi vous présenter **toto**. Il s'agit d'un moteur de blog
minimaliste écrit en **Ruby** et développé par
cloudhead_. J'ai découvert
toto_ grâce à un ami qui en a parlé un
jour sur IRC. L'idée d'un moteur de blog aussi minimaliste m'a plu et je
me suis dit que j'allais l'essayer.

---------------------
Si minimaliste que...
---------------------

... **il tient en 300 sloc** !! Toto utilise en fait le gestionaire
de version bien connu git_ et
Markdown_ pour la
gestion des articles. Autant vous dire que il y a de quoi être content !
Dans ce *"moteur de blog"* enfin si l'on peut dire, pas de place pour
les fioritures et c'est tant mieux ! En fait, ça rentre exactement dans
ma manière de penser : **en faire peu, mais bien le faire** !

---------------------
Mais, pourquoi lui ??
---------------------

Je n'ai jamais ouvert (ou bien fait vivre plus de 2 jours) un blog pour
la simple raison que j'ai **horeur** des interfaces de Wordpress et ses
copains. Je les trouve compliquées et anti-intuitives, surtout quand on
ne cherche qu'a partager à la volée des idées ou des articles. En plus,
ça m'embètait de devoir ouvrir un navigateur web pour poster...
*(flemmard inside)*. **Toto** est donc devenu d'un coup le candidat
idéal :

-  Pas d'interface d'admin compliquée : simplement une arborescence de
   fichiers (et un ``config.ru`` à remplir comme il faut)

-  Pas besoin de passer par HTTP pour poster : on commit sur le dépot
   git

-  Pas besoin de d'apprendre de nouveau outil : j'utilisais déjà
   git_, vim_ et Markdown_ !

-----------
Déploiement
-----------

Observons un peu plus ce que cache notre ami ! Nous l'avons dit plus
haut, toto_ est écrit en Ruby_, il utilise **Rails** et
**Rack**. Pour ce qui est de l'installation de la bestiole, **Toto** se
comporte comme n'importe qu'elle gemme ruby, et peut donc s'installer
avec la commande :

.. code-block:: bash

    gem install toto

Ruby connait désormais **toto** mais on va avoir besoin de templates...
Pour cela, clouhead met à disposition dorothy_, un set de templates
de base pour **toto**. Dorothy est en fait un dépot git qu'il suffit de
cloner à l'endroit voulu :

.. code-block:: bash

    cd la/ou/on/veut
    git clone git://github.com/cloudhead/dorothy.git monblog

Chez moi, **toto** est géré dans un **vhost apache** et répond au
sous-domaine *http://blog.matael.org* : Voici une copie du fichier de
conf du vhost :

.. code-block:: apache 

    <VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName blog.matael.org
        ServerAlias blog
        DocumentRoot /path/to/toto/public

        <Directory /path/to/toto> # Attention : pas de slash de fin
            Allow from All
            Options -Multiviews
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        LogLevel warn
        CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>

Il faut juste bien veiller à faire pointer *DocumentRoot* sur le
**répertoire ``public`` de toto**.

Cloudhead propose aussi une **installation en 10s** au sein d'**heroku**
:

.. code-block:: bash 

    git clone git://github.com/cloudhead/dorothy.git myblog
    cd myblog
    heroku create myblog
    git push heroku master

je n'ai pas utilisé (ni testé d'ailleurs) cette méthode, en effet je
suis pas un énorme utilisateur de Ruby et encore moins de Rails...

-----------------
Je veux écrire !!
-----------------

Voilà enfin ce qui m'a le plus plut : écrire des articles est simple !
On crée un fichier dont le nom est correctement formaté dans le
répertoire ``articles/`` de **dorothy**. La syntaxe attendue pour les
noms de fichiers est : année-mois-jour-titre

avec des tirets à la place des espaces pour le titre. Pour l'exemple
voici le nom de fichier de cet article : 2011-07-04-mon-ami-toto.mkd Par
défaut, **toto** attend des articles en ``.txt`` mais cette
configuration peut être modifiée dans le ``config.ru``.

Pour ce qui est des fichiers-articles, voici leur formatage normal :

.. code-block:: markdown

    title:titre de l'article
    author:Nom Auteur
    date:25/05/2042

    Article.....
    .............

Rien de bien sorcier donc !

Comments

Effectivement, tout blog se doit d'implémenter une possibilité de
commentaire. Ici, c'est **disqus** qui remplit cet usage. La création de
compte est rapide et gratuite ainsi que l'ajout d'un blog. On récupère
ensuite **l'id du blog nouvellement créé** et on le met là où il faut
dans le ``config.ru``.

A propos de ``config.ru``, voici le mien :

.. code-block:: ruby

    require 'toto'

    # Rack config
    use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
    use Rack::CommonLogger

    if ENV['RACK_ENV'] == 'development'
      use Rack::ShowExceptions
    end

    #
    # Create and configure a toto instance
    #
    toto = Toto::Server.new do
      #
      # Add your settings here
      # set [:setting], [value]
      # 
      set :author,     "Mathieu (matael) Gaborit"                # blog author
      set :title,      "Matael..."                               # site title
      # set :root,     "index"                                   # page to load on /
      set :date,       lambda {|now| now.strftime("%d/%m/%Y") }  # date format for articles
      # set :markdown, :smart                                    # use markdown + smart-mode
      set :disqus,     'matael'                                  # disqus id, or false
      # set :summary,  :max => 150, :delim => /~/                # length of article summary and delimiter
      set :ext,        'mkd'                                     # file extension for articles
      # set :cache,    28800                                     # cache duration, in seconds

      #set :date, lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
    end

    run toto

Merci à **cloudhead** d'avoir développé cette application et bonne
chance à tous ceux qui souhaiteraient se lancer avec !!

.. _cloudhead: http://cloudhead.io
.. _toto: http://cloudhead.io/toto
.. _git: http://git-scm.com
.. _Markdown: http://daringfireball.net/projects/markdown/
.. _Ruby: http://ruby-lang.org
.. _dorothy: https://github.com/cloudhead/dorothy
.. _vim: http://www.vim.org/
