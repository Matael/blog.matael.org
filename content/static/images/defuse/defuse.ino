// Définition des couleurs pour la LED
#define R 5
#define G 3
#define B 4

// Définition des fils
#define F1 6
#define F2 7
#define F3 8
#define F4 9

// Définition du bouton : INT0 ;)
#define BUTTON 0

// tableau contenant les numéros de pins OUT de la bombe
volatile int F[4] = {F1, F2, F3, F4};

// la bombe est elle activée ?
volatile int bomb = 0;

// utile pour après
volatile int boom, ouf;


void activate_bomb(){
	// routine d'interruption pour activer la bombe

	// Choisir le fil qui désamorce
	ouf = F[random(4)]+4;

	// Choisir le fil qui fera tout exploser
	do {
		boom = F[random(4)]+4;
	} while (ouf == boom); // en s'assurant qu'il est différent du premier

	// Activation !
	bomb = 1;
}


int critical_sequence() {
	// Essaye donc de désamorcer ;)!

	int i = 10; // T'auras 10s ;)
	while (i>=0) {
		
		// On fait clignoter en bleu
		digitalWrite(B, HIGH);
		delay(100);
		digitalWrite(B, LOW);

		
		// si le fil d'explosion est coupé :
		if (digitalRead(boom) == LOW) {
			return 0; // on renvoie 0
		}

		// si le fil de désamorçage est coupé :
		if (digitalRead(ouf) == LOW) {
			return 1; // on renvoie 1
		}

		// on attends 450 millis
		delay(450);

		// on reteste                    
		if (digitalRead(boom) == LOW) {
			return 0;	
		}

		if (digitalRead(ouf) == LOW) {
			return 1;
		}

		delay(450);	

		// et on décrémente
		i--;
	}
	// si la bombe n'est pas désamorcée au bout du temps,
	// on la fait exploser
	return 0;
}

void setup()
{
	// activation des pins en IN/OUT
	int i;
	for (i = 0; i < 4; i++) {
		// 6 7 8 9 à OUT
		pinMode(F[i], OUTPUT);
		// 10 11 12 13 à IN
		pinMode(F[i]+4, INPUT);
		// On passe les cables au niveau haut
		digitalWrite(F[i], HIGH);
	}

	// On passe à OUT les pins de la LED
	pinMode(R, OUTPUT);
	pinMode(G, OUTPUT);
	pinMode(B, OUTPUT);

	// Init de la random à partir d'une
	// pin analogique non connectée
	randomSeed(analogRead(0));

	// mise en place de l'interruption
	attachInterrupt(BUTTON, activate_bomb, RISING);
}

void loop()
{
	// la bombe est elle activée ?
	if (bomb) {

		// c'est parti !
		int defused = critical_sequence();

		if (defused) { // si le désamorçage a réussi
			// on passe la LED en vert
			digitalWrite(G, HIGH);
		} else { // sinon...
			// ... en rouge !
			digitalWrite(R, HIGH);
		}

		// on attend un peu et on éteind la LED
		delay(1000);
		digitalWrite(G, LOW);
		digitalWrite(R, LOW);

		// On désactive la bombe, tu t'es bien battu
		bomb = 0;
	}
}
