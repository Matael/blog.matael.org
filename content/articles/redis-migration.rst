===============
Redis migration
===============

:date: 2015-01-04 11:28:38
:slug: redis-migration
:authors: matael
:summary: 
:tags: redis, imported

I'm currently trying to migrate all the content from a server (*marvin*) to another (*vogon*, thanks to lidstah for this name).
Moreover, I also want all the services running on the old one to run on the new, and sometimes it's.... annoying.

Some of the websites running on these servers, use a redis_ instance.
Even if I do not store large amounts of data in the databases, I thought it was not elegant to dump everything from *marvin* in order to load it back in *vogon*.

Skimming through the doc, I found an interesting redis feature : one can define a master instance on the fly and replicate data from this master.

master
------

On the *master* side, we just have to check that the ``bind`` parameter is not set in the config file (or to make the server listen the future slave's IP address).
In fact, this parameter specifies which address will be allowed to connect the server.

If this param is set, just add the slave's IP address to the list or comment the line and then restart the server.

slave
-----

On the *slave*, you won't have to modify the config file : just run ``redis-cli`` in a console to access the server and run ::

    SLAVEOF <slave ip or domain name> <port>

Wait a bit (syncing between master and slave is automatic on connection)
For a quite *"small"*  redis instance, the process completes in seconds.

Once syncing's over, just disconnect using ::

    SLAVEOF NO ONE

and... that's all !

Why this is so cool
-------------------

In several ways, this method is powerful :

- if you want to keep the data up-to-date on the future server before migrating the entire app, just do that and disconnect once the migration of the full app is complete.
- if you have set ``bind`` but can't restart the redis server, you can launch another instance locally with a different config file (different port and bind unset or correctly set), accepting external connections and sync with this one instead of the real targeted one (which will probably share data with the other or, if not, will be slave of the root instance).

One more thing
==============

During the whole server migration, I had a problem with a phpBB installation I needed.
Database restoration and hardcore dump from *marvin* and load into *vogon* failed so I decided to migrate everything by hand.

The *working* process is (I'm running PostgreSQL):

1. install dummy instance to force database structure creation
2. empty all the tables in the new DB (phpBB fills it with some data)
3. dump each table data separatly from old server
4. inject this data into the new
5. dump all *sequences* from old server
6. inject it into the new

The two last steps avoid rupture of constraints (particularly on ``post_id`` field)


.. _redis: http://redis.io
