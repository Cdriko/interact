int on1 = 2 ;
int on2 = 3;
//int on3 = 4;
int reset = 0 ;
int reset2= 0 ;
//int reset3= 0;

void setup(){
  Serial.begin(9600);
  pinMode(on1, INPUT);
  pinMode(on2, INPUT);
//  pinMode(on3, INPUT);
}
void loop(){
  reset = digitalRead(on1);
  reset2= digitalRead(on2);
//  reset3= digitalRead(on3);
  
  Serial.print(reset, DEC);
  Serial.print(",");
  Serial.println(reset2, DEC);
/*  Serial.print(",");
  Serial.println(reset3, DEC);*/
  //Serial.print(",");
  //Serial.println(serve, DEC);
}
