////////////////////////////
// Commande du 74HC595    //
// Le 24 Octobre 2011     //
// pour blog.matael.org   //
////////////////////////////

// Comme d'habitude, on défini les pins avec des defines
#define ANA 0    // potar
#define SHIFT 5
#define LATCH 6
#define DATA 7

// Table des trucs à afficher (1 = led allumée)
const byte chars[8] = {
B00000001,
B00000010,
B00000100,
B00001000,
B00010000,
B00100000,
B01000000,
B10000000};

int time_delay = 500; // Delay de base

void setup()
{
	// On déclare les pins vers le 74HC595 en sortie
	pinMode(SHIFT, OUTPUT);
	pinMode(LATCH, OUTPUT);
	pinMode(DATA, OUTPUT);
}

void loop()
{
	int i;
	// On boucle sur le tableau char
	for (i = 0; i < 8; i++) {
	    digitalWrite(LATCH, LOW);  // bloque la recopie
	    // On balance la donnée dans le premier étage
	    shiftOut(DATA, SHIFT, MSBFIRST, chars[i]);
	    digitalWrite(LATCH, HIGH);// recopie
	    // On contrôle le potar pour déterminer le delay
	    time_delay = map(analogRead(ANA), 0, 1023, 10, 500);
	    delay(time_delay);
	}
}
