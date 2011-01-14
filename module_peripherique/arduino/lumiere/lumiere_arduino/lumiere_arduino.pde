// My first from scratch program; Three LED's (Yellow, Orange, Red) light up depending on the brightness of the room (as read by the LDR). With an added data output.
// Allume 3 LED en fonction de la luminosité de la pièce.

#define LEDy  11
#define LEDo  10
#define LEDr  9
#define SENSOR 0

int val = 0;
int val_sensor = 0;

void setup() {

  pinMode(LEDy, OUTPUT);
  pinMode(LEDo, OUTPUT);
  pinMode(LEDr, OUTPUT);
  Serial.begin(9600);
}

void loop() {
val = analogRead(0);

if (val >= 150)
{
digitalWrite(LEDy, HIGH);
digitalWrite(LEDo, LOW);
digitalWrite(LEDr, LOW);
}
  if (val > 65 && val < 150)
{
digitalWrite(LEDy, LOW);
digitalWrite(LEDo, HIGH);
digitalWrite(LEDr, LOW);
}
  if (val <= 65)
{
digitalWrite(LEDy, LOW);
digitalWrite(LEDo, LOW);
digitalWrite(LEDr, HIGH);
}

val_sensor = analogRead(SENSOR);
Serial.println(val_sensor);
delay(1000);
}
