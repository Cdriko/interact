// Controlling a servo position using a temperature sensor
// by Michal Rinott <http://people.interaction-ivrea.it/m.rinott>
// edited 5-12-2010 by Will Lyon to include base setting for servo if voltage not detected on pin 7
// edited again 7-4-2010 by crenn to simplify the code a little
// edited yet again 7-5-2010 by crenn to add features
// edited again 7-21-2010 by Will Lyon - recalibrated servo positions

#include <Servo.h>

Servo myservo;  // create servo object to control a servo

//Constants
const unsigned char CONTROL = 7;	// digital pin used to detect if the system is on or off
const unsigned char temps = 0;		// analog pin used to connect the temp sensor
const unsigned char MAX_VAL = 10;

//Main global varibles
char trigger = 0;			// varible used to store the control pin value
unsigned int val;			// variable to read the value from the analog pin

unsigned int updateAvgtemp(){
	static int history[MAX_VAL]={0};
	static unsigned char lastHist=0;
	static unsigned char numHist=0;
	unsigned int temp=0;
	unsigned char counter=0;
	unsigned char arcount=0;
	history[lastHist] = analogRead(temps);
	if(numHist<MAX_VAL)
		++numHist;
	arcount=lastHist;
	++lastHist;
	if(lastHist>=MAX_VAL)
		lastHist=0;
	temp=0;
	counter=0;
	do{
		temp+=history[arcount];
		arcount--;
		if(arcount>MAX_VAL)
			arcount=(MAX_VAL-1);
		counter++;
	}while(counter < numHist);
	return (temp/numHist);
}

void setup()
{
  pinMode (CONTROL, INPUT);		// sets the control pin to input
  myservo.attach(9);			// attaches the servo on pin 9 to the servo object
  digitalWrite(CONTROL, LOW);		// ensure internal pullup resistor is disabled.
}
void loop()
{
  trigger = digitalRead(CONTROL);	// read input of pin CONTROL  and store it
  if (trigger == HIGH){			// reads if pin CONTROL, if true, do this:
    val = updateAvgtemp();		// read the value of the temp sensor (value with range of 1024)
    val = map(val, 350, 700, 160, 80);	// scale it to use it with the servo (value between 160 and 80)
    myservo.write(val);			// sets the servo position according to the scaled value
  }
  else {
    myservo.write(180);			// sets servo position to 180 if above statment is false
  }
  delay(125);								// wait 25ms for the servo to move to it's new position and also 100ms until it gets the new value
}
