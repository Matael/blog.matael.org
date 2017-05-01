==========================
From Reddit To ReadItLater
==========================

:date: 2015-01-04 11:27:47
:slug: from-reddit-to-readitlater
:authors: matael
:summary: Just wanted to bind reddit.com and readItLater
:tags: reddit, perl, imported

Hi !
First attempt to write a whole article in english on this blog.
As I'm not a native speaker, some of my sentences could sounds a bit strange, please forgive ... or better : let me know ;)

A few months ago, a friend told me about reddit_.
This had been a great discovery for me, and I started using it (a lot).
On reddit, I spend most of my time lurking.

Idea
====

During a discussion, it appears that it could be nice to have a script crawling reddit_ and (matching titles against some pre-defined keywords) adding interesting links to a ReadItLater list.

As I have an android phone with the RIL application installed, this is great !

RIL_ has just been renamed Pocket_ but the principle stay unchanged :

#. append URLs to your *Reading List*
#. Sync between several devices
#. enjoy articles \o/

Connection to reddit
--------------------

As I already knew RIL powers an API_, I had just to find a way to fetch reddit posts.

The easiest way I thought about was to find a generic RSS feed URL and then re-use it.

As I had already seen some reddit applets on websites, I was pretty sure such a thing existed.

I looked at the reddit `gadgets page`_ and found that we can fetch JS code adding ``/.embed`` to a subreddit URL.
As a naive guy, I tried http://reddit.com/r/vim/new/.rss&limit=5&t=all&sort=new . And guess what happened...
I got a beautiful RSS feed **\o/**.

**Note :** The parameters in the URL come from the gadgets page-generated urls.

After a very very short poll, I chose to build the script in perl, for several reasons :

- it has a lot of modules with funny names (``File::Slurp`` for example ;))
- it's installed basically on every Linux system
- installing a new module is easy
- perl is cool

Modules
~~~~~~~

So, I choose perl and the following modules :

- ``XML::RSS:Parser::Lite`` : to parse the feed itself
- ``XML::Parser::Lite`` : required by the first one
- ``Text::Match::FastAlternatives`` : to create easily a *regex* (not a real one) with searched words
- ``YAML`` : to parse config file
- ``File::Slurp`` : to read an entire file (yeah, this name is great)

All these modules are on CPAN_ and installable using :

.. code-block:: bash

    sudo cpan Module::Name

As I'm a nice guy (uh uh...), I also wrote a ``Makefile`` with a ``deps`` target to install everything using :

.. code-block:: bash

    make deps

As I wanted to keep the main script clean, I chose to build a module myself containing the functions I need.

So... I called it ``RedditRIL.pm`` and just added the minimum code :

.. code-block:: perl

    package RedditRIL;
        # .. here will go my code ...
    1; # because a package must end with a true expression

In the first version of this script, I put curly-braces between this to lines of code.
Someone told me (on reddit) that it's not necessary : a package create automatically a new namespace.

Parse config
------------

The goal is to use a config file looking like :

.. code-block:: yaml

    credentials: [login, pass]
    Python: [Internet]
    vim: [unmapping,path]

Using ``File::Slurp`` and ``YAML``, we can get all the data :

.. code-block:: perl

    #!/usr/bin/env perl

    # this is not the module, but the script ;)

    use strict;
    use warnings;
    use 5.010;
    use YAML;
    use File::Slurp;

    my $data =read_file("./RedditRIL.conf") or die ("Error with conf. file $!");
    my $conf = Load($data);

    my $credentials = $conf->{credentials};

So now, we have login information for RIL_ in ``$credentials`` and whole conf in ``$conf``.

Of course, the script will need to *know* this information (particularily the credentials).

Let's add a ``new()`` method to our package :

.. code-block:: perl

    # some atributes
	my $ril_api_key = "my_api_key";
	my $ril_login = "";
	my $ril_pass = "";
	my $ril_url = "";

    # And the new() method
	sub new {
		my $self = shift;
		$ril_login = shift;
		$ril_pass = shift;
		$ril_url = "https://readitlaterlist.com/v2/add?username=$ril_login&password=$ril_pass&apikey=$ril_api_key";
		return $self;
	}

Note that the API Key can be requested on the page dedicated to the API_ itself.

We can now create a new RedditRIL object in the script using :

.. code-block:: perl

    use RedditRIL;

    # ...

    my $api = RedditRIL->new(@{$credentials}[0], @{$credentials}[1]);

And iterate over data from config file, processing subreddits one by one :

.. code-block:: perl

    foreach my $key (keys %{$conf}) {
        next if $key eq "credentials";
        $api->process($key, $conf->{$key});
    }

I think you understood that we'll now write the ``process()`` method which will be passed :

- a reference to the object itself (implicit)
- the name of a subreddit (``$key``)
- the keywords to look for in this subreddit (array reference ``$conf->{$key}``

Processing a reddit
-------------------

.. code-block:: bash

    package RedditRIL;
    {
        use strict;
        use warnings;
        use 5.010;
        use LWP::Simple;
        use XML::RSS::Parser::Lite;
        use Text::Match::FastAlternatives;

        # new() + attributes

        sub process {
            # Process a subreddit,
            # Get a subreddit name & keywords
            # as argument
            my ($self, $sub, $kws) = @_;
            my $data = XML::RSS::Parser::Lite->new();
            $data->parse(get("http://www.reddit.com/r/$sub/new/.rss?limit=5&t=all&sort=new")) or die ("Erf.. a error occured :\n\t$!");
            my $re  = join "|", @{$kws};
            for (my $i = 0; $i < $data->count(); $i++) {
                my $item = $data->get($i);
                if ($item->{title} =~ $re) {
                    $self->add_to_ril($item);
                }
            }
        }
    }

The first line of ``process()`` (right after comments) fetches values passed as arguments :

- ``$sub`` will contain the subreddit name
- ``$kws`` is for the list of searched keywords 

The second one just initialize a RSS Parser whom ``parse()`` method is used on the following line.

For this method, we send an URL containing the ``$sub`` variable (it will be interpolated on evaluation).

The ``die`` clause stops the script if an error occured, printing the error (``$!``) on screen.

Next, we create a simple search **false** *regex* using ``Text::Match::FastAlternatives`` (here with ``join``).

The the script loops over each item of the freshly parsed feed and tests it against the *regex*.

If it matches, we send the item itself to another method : ``add_to_ril()``.

Send it to RIL
--------------

This method simply uses the RIL API_ through its ``add`` method :

.. code-block:: bash

	sub add_to_ril {
		my ($self,$item)  = @_;
		say "+ Adding link $item->{url}";
		get("$ril_url&url=$item->{url}&title=$item->{title}")
            or die ("Unable to upload link to RIL...\n\t$!");
        say("\t=> Done uploading !");
	}

A small reminding prints on screen saying which link we're sending to RIL_.

Then, a simple ``get`` request sends the link itself to RIL, with the title specified on reddit_.

Testing
=======

We can now fill the ``RedditRIL.conf`` file, run the script and see this :

.. code-block:: bash

    $ ./crawler.pl
    + Adding link http://www.reddit.com/r/vim/comments/su21k/map_jj_to_what_exiting_input_mode_but_then/
            => Done uploading !uploading

It works ! Great !

Conclusion
==========

We are now able to add automatically interesting reddit_ links to our RIL_ account.

This sounds nice but we can do even more interesting things. One idea could be the following :

    A script crawls RSS of selected subreddits (specified in the config file), searching for specified keywords.
    This script adds potentialy interesting links to a Redis database. 

    Another provides a minimalist web or cli frontend to this DB allowing the user to up/down vote selectioned links.

    The crawler can change his critera a bit to be more accurate next time according to user's votes.

    A third script takes every link in DB from time to time and sends them to RIL (using ``send`` method for example).

Note that this system can be oriented to feed a (redis) pub/sub channel with a feedback ability.

Maybe I'll improve it....

Here's where you'll find the whole project :

    https://github.com/Matael/reddit_doors

Note
====

I just want to thank :

- my english teacher for her careful reading and corrections to this article
- ronocdh_ for his improvements to my code


.. _reddit: http://reddit.com
.. _RIL: http://readitlater.com
.. _API: http://getpocket.com/api
.. _Pocket: http://getpocket.com/
.. _gadgets page: http://reddit.com/widget
.. _CPAN: http://www.cpan.org
.. _ronocdh: https://github.com/ronocdh
