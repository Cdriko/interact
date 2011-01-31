/******************************************************************************************************************************************************************************
********************************************************************* Code Arduino pour l'instllation LIFE ********************************************************************
********************************************************************** Felix Lepoutre et Jérémy Barré, I2D *********************************************************************
*******************************************************************************************************************************************************************************/
    
int ledPin = 13;                                                         

int analogPin = 0;                                                       
int val = 0;
int sensorValue = digitalRead(13);                                      // le circuit fonctionne avec la sortie numerique 13


void setup()
{
  pinMode(ledPin, OUTPUT);                                              // on definit les leds en tant que sortie numérique
  Serial.begin(9600);
}

void loop()
{
  val = analogRead(analogPin);                                          // on recupere la valeur de la sortie analogue (ici, le capteur de flexion)
  
  if (val > 500){                                                       // lorsque la valeur retournee est superieure a 500, 
  digitalWrite(ledPin,LOW);                                             // les leds sont eteintes
  }  
  
  if ((val < 500) && (val > 400)){                                      // si la valeur retournee est comprise entre 400 et 500
  digitalWrite(ledPin,HIGH);                                            // les leds s'allument
  delay(1000);                                                          // interval de 1 seconde (clignotement) entre les eclairages 
  }
  
  if ((val < 400) && (val > 300)){                                       // si la valeur retournee est comprise entre 300 et 400
  digitalWrite(ledPin, HIGH);                                           // les leds s'allument
  delay(500);                                                           // interval de 500 millisecondes (clignotement) entre les eclairages
  }
  
  if ((val < 300) && (val > 200)){                                       // si la valeur retournee est comprise entre 200 et 300
  digitalWrite(ledPin, HIGH);                                           // les leds s'allument
  delay(250);                                                           // interval de 250 millisecondes (clignotement) entre eclairages
  }
  
  if ((val < 200) && (val > 100)){                                       // si la valeur retournée est inférieure à 500
  digitalWrite(ledPin, HIGH);                                           // les leds s'allument
  delay(50);                                                            // interval de 50 millisecondes (clignotement) entre les eclairages
  }
  
  if (val < 100){                                                       // si la valeur retournée est inférieure à 500
  digitalWrite(ledPin, HIGH);                                           // les leds s'allument 
  }

  
  Serial.println(val);                                                 // indiquent les valeurs dans le monitor toutes les secondes
  delay(1000);
}


