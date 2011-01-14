/*
  Analog sensor reader
  Language: Arduino/Wiring

  Reads an analog input on Analog in 0, prints the result 
  as an ASCII-formatted  decimal value.
  Connections: 
    FSR analog sensor on Analog in 0
*/
int sensorValue;            // outgoing ADC value

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
}

void loop()
{
  // read analog input:
  sensorValue = analogRead(0); 

  // send analog value out in ASCII decimal format:
  Serial.println(sensorValue, DEC);

  // wait 10ms for next reading:
  delay(10);                 
}
