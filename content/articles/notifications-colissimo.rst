=======================
Notifications Colissimo
=======================

:date: 2015-01-04 11:28:41
:slug: notifications-colissimo
:authors: matael
:summary: Fucking API et LCD
:tags: python, arduino, api, imported

Parfois, certaines boites feraient bien de rendre leurs données plus accessibles.
Une de ces boites à qui l'ouverture d'une API publique pourrait profiter est La Poste.

J'attendais depuis quelque jours un colis et je cherchais un moyen d'afficher d'une manière ou d'une autre les
informations de suivi Colissimo quelque part sur mon bureau. Je me suis rendu sur leur `site de suivi`_ et j'ai rentré
mon numéro et là, problème : il n'y a que des images sur cette page dans le genre :

.. image:: /static/images/colissimo/track.png
    :align: center

Rien de bien cool en soi...

Partie 1 : OCR
==============

Mon premier réflexe à été un peu masochiste : *"Tiens ! Ça me donnera l'occasion de jouer avec une lib pour la
reconnaissance de caractères"*.

J'en suis assez vite revenu : aucun lib ne permet de faire ça en *standalone* avec python et sortir l'excellent
Tesseract_ pour ça relevait un peu de la bombe atomique pour déglinguer une taupe.

Je me suis donc rabattu sur ... une API :)

Partie 2 : L'API (trop) bien cachée
===================================

Ayant un téléphone Androïd, j'ai commencé par chercher de ce côté là si une application de suivi existait, et `c'est le
cas`_.

Après installation, on ouvre Wireshark_ et on rentre le numéro de colis dans l'application et là, ô surprise !
Y'a tout plein de jolies requêtes HTTP qui ne demandaient qu'a être sniffées :)

On trouve donc nos éléments :

- un point d'entrée : ``http://www.laposte.fr/outilsuivi/web/suiviInterMetiers.php``
- 3 paramètres :

  - ``key`` qui semble être une clef d'API pour laquelle la valeur ``d112dc5c716d443af02b13bf708f73985e7ee943``
    fonctionne
  - ``method`` qui règle le format de retour : ``json`` et ``xml`` fonctionnnent. Si on ne met rien, une image est
    retournée.
  - ``code`` qui est le code colis.

Pour le format JSON on obtient :

.. code-block:: javascript

    {
        "link" : "http://www.coliposte.net/particulier/suivi_particulier.jsp?colispart=XXXXXXXXXXXXX",
        "date" : "11/05/2013",
        "status" : true,
        "gamme" : "4",
        "message" : "Votre colis est arrivé sur son site de distribution",
        "client" : "Particulier",
        "base_label" : "Coliposte",
        "error" : null,
        "code" : "XXXXXXXXXXXXX"
    }

Reste à coder un petit truc pour faire ça. On va simplement boucler et envoyer le champ ``message`` du JSON vers un
arduino et un écran LCD.

Code python
-----------

Voilà le code python utilisé :

.. code-block:: python

    #! /usr/bin/env python
    # -*- coding:utf8 -*-

    import sys

    from serial import Serial
    from urllib.request import urlopen
    from time import sleep
    from json import loads
    import re

    BASE_URL = "http://www.laposte.fr/outilsuivi/web/suiviInterMetiers.php?"
    KEY = "d112dc5c716d443af02b13bf708f73985e7ee943"
    METHOD = "json"
    PARCEL_NUM = "XXXXXXXXXXXXX"

    URL = BASE_URL+'key='+KEY+'&method='+METHOD+'&code='+PARCEL_NUM

    # init connection
    try:
        conn = Serial('/dev/ttyACM0', 9600)
    except:
        sys.exit

    # boucle infinie
    while 1:
        response = loads(urlopen(URL).read().decode())

        msg = response['message']
        msg = re.sub(r'é', 'e', msg)

        if msg == "Votre colis est arrive sur son site de distribution":
            msg = "Site de distribution"

        for i in range(10):
            conn.write(bytes(msg+'$', 'ascii'))
            sleep(3);

Rien de compliqué donc. J'envoie plusieurs fois le message pour des petits soucis de comminucation lors des tests.
A noter seulement la regex pour remplacer les ``é`` et éviter un problème lors de l'encodage en ascii. Vous noterez
aussi l'ajout d'un ``$`` à la fin de la chaine qui permet de signaler une fin de transmission (voir code pour l'arduino
ci dessous).

Coté Arduino
------------

Pas de schéma pour cette fois ci, il suffit de relier un LCD en mode 4 broches à l'arduino donc selon le patch :::

    Arduino 4 -> LCD D4
    Arduino 5 -> LCD D5
    Arduino 6 -> LCD D6
    Arduino 7 -> LCD D7
    Arduino 8 -> LCD RS (Register Select)
    Arduino 9 -> LCD E (Enable)
    GND -> LCD VSS
    GND -> LCD RW (Read/Write)
    +5V -> LCD VDD
    +5V -> LCD A (rétroéclairage)
    Potar entre +5V et GND -> LCD V0 (contraste)
    Potar entre +5V et GND (un autre) -> LCD K (rétroéclairage)

Ensuite, un peu de code :

.. code-block:: c

    #include <liquidcrystal.h>

    // instanciation du LCD
    LiquidCrystal lcd(8, 9, 4, 5, 6, 7);


    void setup() {
        // init. du LCD
        lcd.begin(16,2);

        // init. de la conn. série
        Serial.begin(9600);
    }

    // buffer d'entrée série et byte d'entrée
    char buffer[32];
    char incoming;

    // Loop
    void loop() {

        // seulement s'il y a des données
        if (Serial.available()) {

            int i;
            // On initialise le buffer à ' '
            for (i = 0; i < 32; i++) { buffer[i] = ' '; }

            // récupération des données depuis la liaison série
            i = 0;
            while (Serial.available() && i < 32) {
                incoming = Serial.read();
                // test pour la valeur sentinelle
                if (incoming != '$') {
                    buffer[i] = incoming;
                    i++;
                } else
                    break;
            }

            // on vide le tampon d'entrée
            Serial.flush();

            // affichage sur le LCD (en deux lignes)
            lcd.clear(); // RAZ
            lcd.setCursor(0,0); // première ligne
            for (i = 0; i < 16; i++) { lcd.print(buffer[i]);}
            lcd.setCursor(0,1); // deuxième ligne
            for (i = 16; i < 32; i++) { lcd.print(buffer[i]);}


            // on attends 4s
            delay(4000);
        }
    }

Et voilà !

Et on arrive à un résultat plutot potable (en tout cas suffisant) :

.. image:: /static/images/colissimo/result.jpg
    :width: 500px
    :align: center

Voilà donc petit contournement simple d'une limitation stupide et injustifiée de cette API Colissimo.

Pourquoi s'obstiner à cacher des API ? Pourquoi ne pas les rendre directement accessibles ? Tout le monde gagnerait du
temps...

.. _site de suivi: http://www.colissimo.fr/portail_colissimo/suivre.do
.. _Tesseract: http://code.google.com/p/tesseract-ocr/
.. _c'est le cas: https://play.google.com/store/apps/details?id=fr.laposte.lapostetracking&hl=fr
.. _Wireshark: http://www.wireshark.org/
