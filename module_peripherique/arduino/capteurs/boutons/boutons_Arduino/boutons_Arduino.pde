/*
surveille l'etat des trois interrupteurs
et transmet leurs etats a l'ordinateur via le port serie
*/

int bouton1 = 2;
int bouton2 = 3;
int bouton3 = 4;
int reset1 = 0 ;
int reset2= 0 ;
int reset3= 0;

void setup(){
  Serial.begin(9600);
  pinMode(bouton1, INPUT);
  pinMode(bouton2, INPUT);
  pinMode(bouton3, INPUT);
}
void loop(){
  reset1 = digitalRead(bouton1);
  reset2= digitalRead(bouton2);
  reset3= digitalRead(bouton3);
  
  Serial.print(reset1, DEC);
  Serial.print(",");
  Serial.println(reset2, DEC);
  Serial.print(",");
  Serial.println(reset3, DEC);

}
