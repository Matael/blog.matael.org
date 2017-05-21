////////////////////////////
// Horloge Binaire        //
// Le 26 juillet 2011     //
// pour blog.matael.org   //
////////////////////////////

// L'heure est à règler ici
#define HEURES 13
#define MINUTES 41
#define SECONDES 0

// Règlage de l'Alarme
#define AL_H 15   // heures
#define AL_M 30   // minutes


// Variables
//    HMS
int heures = HEURES;
int minutes = MINUTES;
int secondes = SECONDES;

//    Alarme
int alarmeSet[] = {AL_H, AL_M};

//    Calcul du temps
unsigned long last = 0;
// Etat de la trotteuse
volatile int trotteuseState = 1;


// Pins
//    Heures
int h1 = 3;
int h2 = 4;
int h4 = 5;
int h8 = 6;
int h16 = 7;
//    Minutes
int m1 = 8;
int m2 = 9;
int m4 = 10;
int m8 = 11;
int m16 = 12;
int m32 = 13;
// Secondes
int s = 1;      // Led trotteuse
// On/off
int on_off = 2; // Bouton pour stoper l'alarme
// alarme
volatile int alarme = 0; // led d'alarme


void affichage()
{
    int minutes_restantes;
    int heures_restantes;
    // Affichage des heures
    if ((heures/16) >=1) { digitalWrite(h16, HIGH);
        heures_restantes = heures%16;} else { digitalWrite(h16, LOW);}
    if ((heures_restantes/8) >=1) { digitalWrite(h8, HIGH);
        heures_restantes = heures%8;} else { digitalWrite(h8, LOW);}
    if ((heures_restantes/4) >=1) { digitalWrite(h4, HIGH);
        heures_restantes = heures%4;} else { digitalWrite(h4, LOW);}
    if ((heures_restantes/2) >=1) { digitalWrite(h2, HIGH);
        heures_restantes = heures%2;} else { digitalWrite(h2, LOW);}
    if ((heures_restantes/1) >=1) { digitalWrite(h1, HIGH);
    heures_restantes = heures%1;} else { digitalWrite(h1, LOW);}
    
    // Affichage des minutes
    if ((minutes/32) >=1) { digitalWrite(m32, HIGH);
        minutes_restantes = minutes%32;} else { digitalWrite(m32, LOW);}
    if ((minutes_restantes/16) >=1) { digitalWrite(m16, HIGH);
        minutes_restantes = minutes%16;} else { digitalWrite(m16, LOW);}
    if ((minutes_restantes/8) >=1) { digitalWrite(m8, HIGH);
        minutes_restantes = minutes%8;} else { digitalWrite(m8, LOW);}
    if ((minutes_restantes/4) >=1) { digitalWrite(m4, HIGH);
        minutes_restantes = minutes%4;} else { digitalWrite(m4, LOW);}
    if ((minutes_restantes/2) >=1) { digitalWrite(m2, HIGH);
        minutes_restantes = minutes%2;} else { digitalWrite(m2, LOW);}
    if ((minutes_restantes/1) >=1) { digitalWrite(m1, HIGH);
        minutes_restantes = minutes%1;} else { digitalWrite(m1, LOW);}
}

void trotteuse()
{
    // --- Fait clignoter la trotteuse toutes les secondes
    digitalWrite(s, HIGH);
    delay(10);
    digitalWrite(s, LOW);
}

void stop_alarme()
{
    // --- Arrête l'alarme
    digitalWrite(alarme, LOW);
}

void alarm()
{
    // --- Vérifie si c'est l'heure et déclenche l'alarme
    if ((heures == alarmeSet[0])
        && (minutes == alarmeSet[1])
        && secondes == 0) {
        digitalWrite(alarme, HIGH);
    }

}

void setup()
{
    // pin Output
    pinMode(h1, OUTPUT);
    pinMode(h2, OUTPUT);
    pinMode(h4, OUTPUT);
    pinMode(h8, OUTPUT);
    pinMode(h16, OUTPUT);
    pinMode(m1, OUTPUT);
    pinMode(m4, OUTPUT);
    pinMode(m8, OUTPUT);
    pinMode(m16, OUTPUT);
    pinMode(m32, OUTPUT);
    pinMode(s, OUTPUT);
    pinMode(alarme, OUTPUT);
    // bouton
    pinMode(on_off, INPUT);
    // initialisation de la trotteuse
        // et de l'alarme
    digitalWrite(s, LOW);
    digitalWrite(alarme, LOW);
    // Mise en place de l'interruption pour
        // l'arrêt de l'alarme
    attachInterrupt(0, stop_alarme, RISING);
    // premier affichage
    affichage();
}

void loop()
{
    if ((millis()) - last  >= 1000) {
        last = millis();
        trotteuse(); // fait clignoter la trotteuse
        secondes++;  // Incrémentation des secondes
        if (secondes >= 60) {
            minutes++; // 60 secondes : +1 minute
            secondes = 0;
        }
        if (minutes >= 60) {
            heures++; // 60 minutes : +1 heure
            minutes = 0;
        }
        if (heures >= 24){
            heures = 0; // changement de jour
        }
        alarm(); // Vérification pour l'alarme
        affichage(); // affichage de l'heure
    }
}
// vim: ft=arduino ts=4 sw=4 et autoindent number
