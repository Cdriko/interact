#define echoPin 2                            // Pin to receive echo pulse
#define trigPin 3                            // Pin to send trigger pulse

void setup(){
  Serial.begin(9600);
  pinMode(echoPin, INPUT);
  pinMode(trigPin, OUTPUT);
}

void loop(){
  digitalWrite(trigPin, LOW);                   // Set the trigger pin to low for 2uS
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);                  // Send a 10uS high to trigger ranging
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);                   // Send pin low again
  int distance = pulseIn(echoPin, HIGH);        // Read in times pulse
  distance= distance/58;                        // Calculate distance from time of pulse
  Serial.print(distance, DEC); 
  Serial.print('\n');
  //Serial.print('\n');    
  delay(50);                                    // Wait 50mS before next ranging
}


