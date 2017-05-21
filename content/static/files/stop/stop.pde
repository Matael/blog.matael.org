/////////////////////////////
// Gestion d'Interruptions //
// Le 19 Aout 2011         //
// pour blog.matael.org    //
/////////////////////////////

// Nombre de leds
#define NOMBRELEDS  8

// Leds (dans un tableau parce que c'est plus simple à parcourir)
volatile int leds[] = {4,5,6,7,8,9,10,11};

// Pin du Bouton
int buttonPin = 2;

// Durée du delay
int timer= 100;

// Marche/Arret
volatile int pauseState = 0;

// Routine de gestion d'interruption
void pause()
{
    pauseState = 1 - pauseState;
}

void setup()
{
    int i;
    // On déclare les pins des LEDs en sortie
    for (i = 0; i < NOMBRELEDS; i++) {
        pinMode(leds[i], OUTPUT);
    }
    // ... et le bouton en entrée
    pinMode(buttonPin, INPUT);
    // On lie l'interruption à la pin qui va bien (pin 2 -> inter0)
    attachInterrupt(0, pause, RISING);
}

void loop()
{
    int i; // variable d'itération
    digitalWrite(leds[0], HIGH);
    for (i = 0; i < NOMBRELEDS; i++) {
        // Si on est en mode pause : on attend
        while (pauseState == 1) { delay(1); }
        delay(timer);
        digitalWrite(leds[i-1], LOW);
        digitalWrite(leds[i], HIGH);
    }
    // et on repart dans l'autre sens !
    for (i = NOMBRELEDS -1 ; i >= 0; i--) {
        while (pauseState == 1) { delay(1); }
        delay(timer);
        digitalWrite(leds[i+1], LOW);
        digitalWrite(leds[i], HIGH);
    }
}

// vim: ft=arduino ts=4 sw=4 et autoindent number
