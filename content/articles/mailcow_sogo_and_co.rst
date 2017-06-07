===================
Mailcow, SOGo & Cie
===================

:date: 2017-06-07 18:00:00
:slug: mailcow-sogo-and-cie
:authors: matael
:summary: Personal server 101
:tags: mail, tips, sysop

After a few months (years) of laziness, I cut on the procrastination habit and decided to
install a mail/\*Dav server. Because I'm very lazy when it comes to system admin, I wanted
something as simple as possible to install while still being nice to use. Also, I hate
configuring Postfix, we all do.

A friend_ pointed me to Mailcow_ and (spoiler alert) it turned out great!
Amongst the capabilities I was looking for, it has all:

- IMAP/POP3/SMTP
- Webmail (sexy if possible)
- CalDAV/CardDAV
- Multidomain

The concept of mailcow is to propose a nicely packaged suite that installs itself. It's
built on top of Postfix_/Dovecot_, a database (MySQL_ or MariaDB_) and proposes to install a
webmail (SOGo_ or Roundcube_) with Apache_ or nginx_ as a webserver and `Let's Encrypt`_
certificates, ClamAV_ and SpamAssassin_ as protections. So yeah... I can hear purists screaming that
if you don't install Postfix by yourself you don't deserve a beard. On the other hand:

- I installed Postfix several times and I still have no beard.
- You'll never get actual non-geek humans take control of their digital lives with
  complicated software.

I went for SOGo as the webmail (which forces MySQL as database server) since it had the
\*DAV capabilities.

  **Note**

  Mailcow seems to move towards a dockerized approach. I'm still skeptical on Docker_ and
  I would not trust it in production. I'm not a sysop and I have no cllue how to debug it
  if it fails!

Step 1: Provisionning the server
================================

This is usually one of the toughest choice... I decided to move all my personal services
to ScaleWay_, a French cloud provider on the cheap. I went for a VCS1_ (virtual) instance
with 2Go of RAM, 50Go SSD and a 1 core x86. If needed, I'll upgrade!

What you want to do if provisioning at ScaleWay's is to:

- Create an account
- Generate and add a *new* ssh key *with a passphrase* (learn yourself a ``ssh-agent`` for great
  good)
- Go to *Security*, add a Security Group name "Mailservers" and **deselect "Block SMTP"**
- Go back to *Servers* and create a server with the last version of Ubuntu_

If you don't do the Security Group thing, you'll need a hard reboot afterwards to be able
to send mails.

Step 2: Domain name
===================

While ScaleWay is starting up your box, copy the IP that has been reserved for you (not
the *private* one) and go to a domain name registrar (I'm at Gandi_ but that's just a
possibility), then buy a domain name you like. If you already have one, take a nap.
For easier reference, I'll use the IP 1.2.3.4 and domain name bad.sex.

In your administration interface for the domain name, find a way to modify the *Zone*
because we will add a few records. I systematically put a 3h TTL on the records (the 10800
bit below) if you have another policy, you probably know what you're doing.

  **Tip**

  If your domain name is brand new, start by *wiping* completely the zone file: the
  default records are registrar's service that you'll probably not use (you wouldn't be
  reading an article on how to configure a mail server). Also, add a **A** record pointing
  to your IP for the domain itself and the ``www`` sub-domain.

  .. code-block:: bind

    @ 10800 IN A 1.2.3.4
    wwww 10800 IN CNAME bad.sex.

We will put the webmail at mail.bad.sex, we need a **A** record for that (you can use a
**CNAME** if the mail server is supposed also to serve at bad.sex):

.. code-block:: bind

  mail 10800 IN A 1.2.3.4

Also, it's a mail server: add a **MX** record:

.. code-block:: bind
  mail 10800 IN MX 10 mail.bad.sex

We'll come back to that and add a few more records later but for now, save and make sure
the zone is active.

  **Tip**

  According to the same friend_, it seems that new records propagates faster than
  modification of existing ones. You probably want to work that around :)

One last thing, you want to go back to ScaleWay's *Network* tab and configure your reverse
DNS to mail.bad.sex. Some mail servers will refuse mail from you if you have an improperly
configured reverse DNS (**PTR** record errors & greylisting ahead).


Step 3: Get and install Mailcow
===============================

So, the server should be up now. Connect as root with the right identity file and create
yourself a sudo-enabled user::

  local $ ssh-keygen -t ecdsa
        ....
        .... Generate ~/.ssh/id_ecdsa_mailserver.pub
        ....
  local $ scp  ~/.ssh/id_ecdsa_mailserver.pub root@1.2.3.4:
  local $ ssh root@1.2.3.4
  remote $ useradd god -m -s /bin/bash -G sudo
  remote $ mkdir /home/god/.ssh/
  remote $ mv id_ecdsa_mailserver.pub /home/god/.ssh/authorized_keys
  remote $ apt-get update && apt-get upgrade

Then, try logging in with your new ``god`` account to the server and try ``sudo -s`` to
make sure you have the right privileges. If so, go back to the root shell and edit
``/etc/ssh/sshd_config`` and make sure the line::

  PermitRootLogging no

exists and is uncommented.


  **Note**

  Here, I used version 0.14, up to date when as I write this post. If you want to check
  the latest one, use `one of these`_.

Log in as ``god`` and use the following lines to get mailcow::

  local $ ssh god@mail.bad.sex
  remote $ mkdir ~/mailcow_build ; cd ~/mailcow_build
  remote $ wget -O - https://github.com/andryyy/mailcow/archive/v0.14.tar.gz | tar xfz -
  remote $ cd mailcow-*

Edit the mailcow configuration file to reflect your domain name and expected setup::

  mailcow config file


At this point, you probably want to verify that your DNS are propagated::

  local $ dig A mail.bad.sex
  local $ dig MX mail.bad.sex

Both should point to the same IP and this IP should be the one of your server.

When you're sure that your DNS records are propagated, start the installer and reply to
the questions::

  remote $ sudo ./install.sh

Elevated privileges are required because the script is install packages and writing config
files here and there. I can't stress enough that this guide may be useful but is not a
doc: **read the doc of mailcow** and get to know what is done by ``install.sh``.

At the very end, the scripts gives you a very great advice: save ``installer.log`` in a
safe place. This file contains passwords for the database and administrative interface.

Step 4: Admin
=============

Once this is done, you should be able to point a browser to mail.bad.sex and see
something. It's supposed to be a login form to the mailcow's administration. Use the
credentials provided in ``installer.log`` and log in as *admin*. You'll be able to edit
some general settings and, in the top right corner you'll find a drop-down menu proposing
*Mailboxes Administration*.

In this section, you'll be able to add domains, admins and regular users.
Use the first block to add a domain, giving it the name you want, the URL mail.bad.sex and
tick the two checkboxes. Then add an admin user for this domain and go back to the
previous admin panel.

You'll now be able to generate the DKIM record for the new domain. Do it and copy the records value.
This has to be added to the domain's zone. Go back to your domain's zone and add two records:

.. code-block:: bind

  mail 10800 IN TXT "v=spf1 mx ~all"
  mail_domainkey 10800 IN TXT "<DKIM record here>"

Go grab a coffee so it all has the time to propagate (10-20 minutes for me) and come back
for the last part.

Step 5: Testing
===============

We now want to test things. Go to ``https://mail.bad.sex/SOGo`` and enters one of you
users' credentials. Aside, open a terminal and connect to the server to monitor the mail
queue::

  local $ ssh god@mail.bad.sex
  remote $ sudo -s
  remote $ watch mailq


From SOGo's web interface, try sending a mail to another mail address and *vice versa*.
Observe the mail queue to see if something gets blocked. To resend *all* messages from the
queue, use ``postqueue -f``

All should work.

Bonus: Close unneeded ports
===========================

It's always a good idea to reduce the attack surface as much as you can. To this end we
will use ``ufw`` (micro firewall) and set some rules::

  local $ ssh god@mail.bad.sex
  remote $ sudo -s
  remote # apt-get install ufw
  remote # ufw allow ssh
  remote # ufw allow http
  remote # ufw allow https
  remote # ufw allow smtp
  remote # ufw allow pop3s
  remote # ufw allow imaps
  remote # ufw enable

Be careful to **authorize ssh before starting the firewall**. If you failed at that,
well... that's too bad but you're now locked out! Try using Scaleway's console but I'm not
even sure it'll be sufficient.

  **Tips**

  If you have to recreate a server, make sure to kill this one before and reuse the same IP
  so you wont have to change your DNS records.

Conclusion
==========

So here it is! You now have a working mail server that can host several domains, provide
sync-able calendars and contact book. The installation is kinda clean and more or less
protected which is better than most of mails servers.

.. _friend: https://twitter.com/seb_vallee
.. _Mailcow: https://mailcow.email/
.. _Postfix: www.postfix.org/
.. _Dovecot: https://www.dovecot.org/
.. _MySQL: https://www.mysql.com
.. _MariaDB: https://mariadb.org/
.. _SOGo: https://sogo.nu/
.. _Roundcube: https://roundcube.net/
.. _Apache: https://httpd.apache.org/
.. _nginx: https://nginx.org
.. _Let's Encrypt: https://letsencrypt.org/
.. _ClamAV: https://www.clamav.net/
.. _SpamAssassin: https://spamassassin.apache.org/
.. _ScaleWay: https://www.scaleway.com/
.. _VCS1: https://www.scaleway.com/virtual-cloud-servers/
.. _Ubuntu: https://ubuntu.com
.. _Gandi: https://gandi.net
.. _one of these: https://github.com/mailcow/mailcow/releases
.. _Docker: https://www.docker.com/
