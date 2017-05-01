===========================
Yet another project : Links
===========================

:date: 2015-01-04 11:28:38
:category: imported
:slug: yet-another-project-links
:authors: matael
:summary: URLs reminder over BottlePy and MongoDB
:tags: python,bottle,mongodb,lesscss

In june, I talked about `technical choices`_ for a web-based todo-list management app (article in french).
The main goal of this project was to try out redis_.
It was a success, and I've recently added redis_ in a most important project.

One of the tools I wanted to test was MongoDB_.
As I did for Redis, I first give a look to The `Little MongoDB Book`_ to get some informations about mongo.

What's MongoDB
==============

The best known concept about MongoDB_, is that's a NoSQL storage system.
It provides several layers to access data ::

    +------------------------+
    |         U S E R        |
    +------------------------+
                V   First you connect the server
    +------------------------+
    |  C O N N E C T I O N   |
    +------------------------+
                V   Then you choose a `DB'
    +------------------------+
    |     D A T A B A S E    |
    +------------------------+
                V   Then a `collection'
    +------------------------+
    |  C O L L E C T I O N   |
    +------------------------+
                V   Then you `documents'
    +------------------------+
    |    D O C U M E N T S   |
    +------------------------+
  

Mongo uses BSON format to store data and is a schema-less system : this means that you can store completly differents *documents* in the same *collection*.

Finally, you have that it provides drivers for a lot of languages.
For this project and article, I've chosen ``pymongo`` which is the *recommended* driver for **python**.

About the project
=================

The project itself is quite simple.
We want to show a list of interesting URLs that any user can feed.

We'll need 2 pages :

- the list itself (answering the route */*)
- the form to add a link (route : */new*)

Each time a link is clicked, we'll increment a hits counter.

This small app will be enough to talk about most important concepts of MongoDB.

Coding
======

First of all, let's write the basic code of a BottlePy_ app :

.. sourcecode:: python

    #!/usr/bin/env python2
    #-*- encoding: utf8 -*-

    # Links app

    import sys
    import os
    from datetime import datetime
    from bson.objectid import ObjectId
    import pymongo
    from bottle import\
            run, \
            debug, \
            request, \
            static_file, \
            get, \
            post, \
            redirect, \
            jinja2_template as template

    # MongoDB db name
    DBNAME="links"
    # Absolute path to static files
    STATIC_ROOT="/home/matael/workspace/learn/python/links/static"

    #### Generic Views ####

    @get('/static/<filename:path>')
    def send_static(filename):
        """ Serves static files """
        return static_file(filename, root=STATIC_ROOT)

    # here will go the code

    # for debug purpose only
    debug(True)
    run(reloader=True) # reload everytime a file changes

Looking at this short piece of source code, we can spot a few things :

- ``jinja2`` will be used for templating
- ``datetime`` is here just for sorting
- ``bson`` will be useful to work with the automatically added ``_id`` field.
- ``DBNAME`` identify the database name in mongo

We'll also need a base template :

.. sourcecode:: html+django


    <!DOCTYPE html>
    <html lang="en">
        <head>
            <title>Links</title>
            <meta charset="utf8"/>
            <link href='http://fonts.googleapis.com/css?family=Overlock' rel='stylesheet' type='text/css'>
            <link rel="stylesheet/less" href="static/main.less" type="text/css"/>
            <script type="text/javascript" src="static/less-1.3.0.min.js"></script>
        </head>
        <body>
            <header>
            <h1><a href="/">Links</a></h1>
            </header>
            <section>
            {% block content %}{% endblock %}
            </section>
            <footer>
            <p><a href="http://sam.zoy.org/wtfpl/">WTFPL</a> 2012 | Powered by <a href="https://github.com/Matael/links">Links</a> - <a href="http://blog.matael.org">Matael</a> | <a href="/new">Add</a></p>
            </footer>
        </body>
    </html>

Nothing to say here. Just note we'll render our stylesheet using LessCSS_

Database connection
-------------------

Let's write a function make database connection easier :

.. sourcecode:: python

    #### Tools ####
    def connect_db():
        db = pymongo.Connection()   # Connect instance
        db = db[DBNAME]             # Select the right DB
        return db.links             # Return a cursor on the right collection

Ok. So we have a base *and* a easy way to connect the db and collection.

Data structure
--------------

Each entry will be recorded a hashtable like this one :

.. sourcecode:: javascript

    {
        _id: ObjectId('the id'), // automatically generated
        poster: "poster's pseudo",
        url: "http://example.com",
        title: "The title",
        hits: 42, // how many times the link had been clicked
        date: date(the date) // insert date
    }


Home
----

Let's write the handler for */* :

.. sourcecode:: python

    @get('/')
    def home():
        """ Home page for a GET request """
        db = connect_db() # connection to DB

        # fetch all entries, sorting them by date descending
        result = db.find().sort('date', pymongo.DESCENDING)

        # render the template
        return template("templates/home.html", result=result)

This view is quite simple and easy to understand.
``find`` and ``sort`` are two standard MongoDB commands.
The first one fetch *documents* and the second... sort them (here, by descending
dates).

The corresopnding template is the following :

.. sourcecode:: html+django

    {% extends 'templates/base.html' %}
    {% block content %}
    <article>
        {% for r in result %}
        <p class="link">
            <span class="l_hits">{{r['hits']}}</span>
            <span class="l_link"><a href="/goto/{{r['_id']}}">{{r['title']}}</a></span>
            <span class="l_poster">par {{r['poster']}}</span>
        </p>
        {% endfor %}
    </article>
    {% endblock content %}

First line explain that this code will go into another template.
Then we specify the *block* where to put the HTML (here, *content*).

On the 7th line, we have a link to the page */goto/<id>*, it's in this view
we'll count hits.

Add a link
----------

Ok, the following view is a bit more complex.

First, the same view will answer GET and POST request, so  we'll need to adapt
the comportement the the type of request :

.. sourcecode:: python

    @post("/new") # answer POST requests on /new...
    @get("/new")  # ... and GET
    def new_link_form():
        """ display the form for adding a link """

        # if it's not a POST request
        if not request.POST:
            # just render the template
            return template("templates/form.html")


        # we are sure it's a POST request
        # poster and url are required, check if we know them
        if request.POST.get("poster") and request.POST.get("url"):

            # just put require info in real variables
            poster = unicode(request.POST.get("poster").strip(), 'utf8')
            url = unicode(request.POST.get("url").strip(), 'utf8')
            try:
                # we probably do not have a title
                title = unicode(request.POST.get("title").strip(), 'utf8')
            except KeyError:
                # if we don't, just set the url as a title for itself
                title = url

            # Connect the Database and collection
            db = connect_db()

            # insert the new link
            db.insert({
                'url': url,
                'title': title,
                'poster': poster,
                'hits': 1,
                'date': datetime.now()
            })

            # close the connection
            db.database.connection.disconnect()

            # go back to the main page
            redirect('/')

        # informations are missing, redirect to the form
        else: redirect('/new')

I think, even if this view is a bit more complex, it's fairly understandable
thanks to the comments provided.

The template itself is really easy (``<table>`` is there for design purposes
only ;) ) :

.. sourcecode:: html+django

    {% extends 'templates/base.html' %}
    {% block content %}
    <article>
        <form action="/new" method="post">
            <table>
            <tr><td><label for="form_url">Link :</label></td>
                <td><input type="text" name="url" id="form_url"></td></tr>
            <tr><td><label for="form_title">Title :</label></td>
                <td><input type="text" name="title" id="form_title"></td></tr>
            <tr><td><label for="form_poster">Poster :</label></td>
                <td><input type="text" name="poster" id="form_poster"/></td></tr>
            </table>
            <input type="submit" value="Yeah !"/>
        </form>
    </article>
    {% endblock %}

Count hits
----------

This is the final view we have to write.
When a user clicks a link, he goes to */goto/<id>* where *<id>* is the ObjectId
of the MongoDB object.

Let's try (there is no template ;) ):

.. sourcecode:: python

    @get("/goto/<id>")
    def goto(id):
        """ Increments hits counter and redirect to the link """

        # connect db and collection
        db = connect_db()

        # update the document (ObjectId function is provided by BSON)
        # $inc is a mongoDB helper to increment a fields without fetching the
        # previous value
        db.update({"_id": ObjectId(id)}, {"$inc": {"hits": 1}})

        # Then fetch the object URL
        url = db.find_one({"_id": ObjectId(id)})['url']

        # Close the connection
        db.database.connection.disconnect()

        # and redirect user to his real destination ;)
        redirect(url)

Note the ``$inc`` construction. It's one the most interesting MongoDB_'s
feature, and it's explained here_

Stylesheet
----------

The last thing I didn't dive yet is the LessCSS_ stylesheet : you'll find it in
the `github repo`_ (in *static/*).

Conclusion
==========

Once again, this app is not perfect. And it wasn't the goal.
I wanted just to work with MongoDB_ to understand better its mechanisms.
The experiment is successful : mongo is really interesting to use and could be
extremely helpful in some situations.

The entire code of this app is released under the WTFPL_ and all feedback is
welcome.

I hope you've learned things ;)


.. _technical choices: http://blog.matael.org/writing/choix-techniques-pour-une-todolist-web/
.. _redis: http://redis.io
.. _MongoDB: http://mongodb.org
.. _BottlePy: http://bottlepy.org
.. _LessCSS: http://lesscss.org/ 
.. _Little MongoDB Book: http://openmymind.net/2011/3/28/The-Little-MongoDB-Book/
.. _github repo: https://github.com/Matael/links
.. _here: http://www.mongodb.org/display/DOCS/Updating 
.. _WTFPL: http://sam.zoy.org/wtfpl/ 
