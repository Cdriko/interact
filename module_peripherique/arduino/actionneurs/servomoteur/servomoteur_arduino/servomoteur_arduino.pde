// Controller la position d'un servo avec un potentiomètre (résistance variable) 
// by Michal Rinott <http://people.interaction-ivrea.it/m.rinott> 

#include <Servo.h> 

Servo myservo;  // cree l'objet servo

int potpin = 0;  // Pin auquel le potentiometre est connecte
int val;    // variable pour lire la valeur d'entree 

void setup() 
{ 
  myservo.attach(9);  // attache le servo au pin 9 
} 

void loop() 
{ 
  val = analogRead(potpin);            // lit la valeur du potentiometre(valeur entre 0 et 1023) 
  val = map(val, 0, 1023, 0, 179);     // mis a l'echelle pour commander le servo (valeur entre 0 et  180) 
  myservo.write(val);                  // regle la position du servo 
  delay(15);                           // attend que le servo soit arrive
} 
