=========================
Contrôlons Nos Cafetières
=========================

:date: 2015-01-04 11:20:58
:slug: controlons-nos-cafetieres
:authors: matael
:summary: 
:tags: arduino, python, twitter, imported

A force de jeter un coup d'oeil sur les blogs de différentes
personnes/organisations, j'ai fini par tomber sur celui du **LOL**
(`Laboratoire Ouvert Lyonnais`_) et sur le projet
de serveur **HTCPCP**. Ce truc m'a plut et j'ai eu envie de tester la
chose.

------
HTCPCP
------

Il faut savoir que les standards de l'internet (et de l'informatique en
général) sont donnés dans des **RFC** (*Request For Comments*) et que,
souvent, le 1er Avril sort une **RFC** fantaisiste.

Le 1er Avril 1998 est parue la **RFC2324** intitulée : *Hyper Text Coffe
Pot Control Protocol (HTCPCP/1.0)*. Ce texte défini une série de règles
pour contraindre un protocole de contrôle hyper texte des cafetières.

~~~~~~~~
Méthodes
~~~~~~~~

La RFC2324 énumère les méthodes utilisée pour l'envoi et la requète de
données au serveur :

-  **BREW**/**POST** : permet le lancement d'actions (**POST** est
   désapprouvé)
-  **GET** : permet de récuperer le café
-  **PROPFIND** (*WEBDAV*) : permet d'atteindre les métadonnées liées au
   café
-  **WHEN** : permet de stopper l'adjonction de lait si besoin

~~~~~~~
Headers
~~~~~~~

La RFC2324 définit quelques headers dont ``accept-additions`` pour
ajouter des choses dans le café (lait, alcool, autre...).

~~~~~~~~~~~~~~~
Codes de retour
~~~~~~~~~~~~~~~

Les codes de retour utilisé sont :

-  **406 Not Acceptable**
-  **418 I'm A Teapot** : le serveur est une théière

Il existe au moins 2 implémentations serveur de la fameuse erreur 418 :

-  à la `BBC`_
-  chez `un geek`_

---------
Le client
---------

Des implémentations de la partie client existent. On prendra par exemple
le cas d'emacs et du script emacs-lisp
`coffee.el`_

Créer un client vers un serveur **HTCPCP** n'a rien de très compliqué en
soi.

----------
Le Serveur
----------

A ma connaissance, aucun vrai serveur **HTCPCP** n'existe à ce jour et
il a de fortes chance que le **LOL** soit le premier organisme à en
écrire un.

Pour ma part, je me suis contenté d'écrire un script python d'interface
entre twitter et un arduino pour le contrôle de ma cafetière via le
réseau social, on y revient un peu plus tard.

-----------
De mon côté
-----------

De mon côté, j'ai voulu réaliser un proof of concept pour le contrôle
d'une cafetière depuis twitter, via un arduino.

En gros, j'utilise une liaison série entre un PC (ou un script s'occupe
de vérifier sur twitter s'il faut envoyer la sauce) et un arduino qui se
charge de commuter l'alim de la cafetière.

Tout le code est sous **license WTFPL** et disponible `sur
github`_.

*Note :* la conception du fameux circuit de commutation relève de la
pure électronique et ne devrait pas tarder.

~~~~~~~
Arduino
~~~~~~~

Le code pour arduino est trivial, je reviendrais sur l'utilisation de la
liaison série dans un autre article.

Il vous faut quand même savoir (pour comprendre mes comparaisons à 48 et
49) que la laison est en **ASCII** et que d'après ce *charset* :

-  0 = 48
-  1 = 49

Voilà le code (plus commenté que la version du dépot) :

.. code-block:: c

    // Ceci est un sketch arduino pour interagir avec un PC et une cafetière
    //
    // Date : 12/2011
    // Auteur : Mathieu (matael) Gaborit
    // License : WTFPL
    //
    // ---------------------------------------------------------
    // Controles :
    // -> liaison vers la caftière => pin13
    // -> USB => Rx/Tx (géré via la lib Serial)
    // -> Code de contrôle :
    // - [Rx] 1 => lancer l'infusion
    // - [Rx] 0 => Stopper l'infusion

    #define COFFEE_POT 13 // pin de contrôle vers la cafetière

    void setup()
    {
        pinMode(COFFEE_POT, OUTPUT);
        Serial.begin(9600); // Init. de la laison série
    }

    void loop()
    {
        // si on a au moins 1 caractère dans le buffer ...
        if (Serial.available() != 0){
            int read_out = Serial.read(); // on le lit
            if(read_out == 49){ // si c'est un "1" (ASCII:49)
                digitalWrite(COFFEE_POT, HIGH); // on lance la cafetière
                Serial.println("Starting coffee pot..."); 
            } else if (read_out == 48) { // si c'est un "0" (ASCII:48)
                digitalWrite(COFFEE_POT, LOW); // on arrête la cafetière
                Serial.println("Stopping coffee pot... :'(");
            } else {
                // sinon, on écrit sur la liaison que le code
                // de controle n'est pas bon
                Serial.println("Bad control code....");
            }
        }
    }

------
Python
------

La liaison avec twitter se fait via le module
`python-twitter`_ et celle
avec l'arduino via le module
pySerial_

Voilà une version sur-commentée de la bête :

.. code-block:: python

    #!/usr/bin/env python2
    #-*- encoding: utf-8 -*-
    #
    # bridge.py
    #
    # 12/2011 Mathieu Gaborit <mat.gaborit@gmx.com>
    # License : WTFPL

    import sys
    import os
    import twitter # le fameux module python-twitter
    import time
    import re # les regexs
    import serial # le module série

    #############################################
    ################# S E T U P #################
    #############################################

    consumer_key = '' # clé d'API twitter pour le compte lié à la cafetière
    consumer_secret = '' # Code secret pour le compte de la cafetière
    master_name = u'' # pseudo twitter du maitre de la cafetière
    serial_port = "/dev/ttyACM0" # port série vers l'arduino
    re_start = re.compile('givemecoffee') # motif à matcher pour la mise en route
    re_stop = re.compile('thanksforcoffee') # motif à matcher pour l'arrêt
    update_time = 30 # temps séparant deux vérification de tweet (en secondes)

    #############################################


    def do_coffee(api, ser):
        """Must i send a signal to the coffee pot ?"""

        # on récupère la dernière mention pour la cafetière
        mention = api.GetMentions()[:1] 
        if mention[0].user._screen_name == master_name:
            # si elle vient du maître, on la traite...
            if re_start.search(mention[0].text):
                # si on trouve le motif de lancement...

                print("Hey ! Let's make coffee !")
                ser.write('1') # on envoie un 1 sur la liaison série
                return 0

            elif re_stop.search(mention[0].text):
                # si on trouve de motif d'arrêt

                print("Yeah ! Coffee's ready !")
                ser.write('0') # on envoie un 0 sur la liaison série
                return 0
        else: # sinon, on attend
            print("Waiting for a tweet...")
            return 0


    def main():
    # créons une instance de la classe d'API
    try:
        api = twitter.Api(
            consumer_key=consumer_key,\
            consumer_secret=consumer_secret,\
            access_token_key='87711832-0X6wvXnI8mxByu4PrxFO8XVa6uLyBgcLSA6jrXMw',\
            access_token_secret='mNcosbbAkHtNubTztJuW9bjBArN60sTgcAUTm6dmX4')
        print("Connected to the twitter API")
    except:
        print("Failed to load twitter API")

    try:
        # on tente d'initialiser la liaison série
        ser = serial.Serial(port=serial_port)
        print("Serial Connection opened...")
    except:
        print("Failed to load serial connection")

    print("Entering main loop....")
    while 1:
        do_coffee(api, ser)
        time.sleep(update_time)
    return 0

    if __name__ == '__main__': main()

Si vous mettez le tout en branle, vous remarquerez que la led sur la pin
13 s'allume quand on envoie le pattern de début et s'éteint à la
recpetion du pattern de fin. Il ne me reste qu'a créer ce circuit de
commutation et tout sera OK !

-----
Liens
-----

-  Wikipedia : `(fr) HTCPCP`_
-  Wikipedia : `(en) HTCPCP`_
-  `python-twitter`_
-  pySerial_
-  le site du `Laboratoire Ouvert Lyonnais`_
-  le site `asciitable.com`_
-  la RFC2324_
- le projet `sur github`_


 .. _Laboratoire Ouvert Lyonnais: http://labolyon.fr
 .. _BBC: http://www.bbc.co.uk/cbeebies/418
 .. _un geek: http://134.219.188.123/
 .. _coffee.el: http://www.northbound-train.com/emacs-hosted/coffee.el
 .. _sur github: https://github.com/Matael/Arduino-CoffeePot
 .. _pySerial: http://pyserial.sourceforge.net/
 .. _python-twitter: http://code.google.com/p/python-twitter/
 .. _(fr) HTCPCP: http://fr.wikipedia.org/wiki/Hyper_Text_Coffee_Pot_Control_Protocol
 .. _(en) HTCPCP: http://en.wikipedia.org/wiki/Hyper_Text_Coffee_Pot_Control_Protocol
 .. _asciitable.com: http://www.asciitable.com/>`_
 .. _RFC2324: http://datatracker.ietf.org/doc/rfc2324/_
