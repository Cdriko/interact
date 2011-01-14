
import processing.serial.*; 
import oscP5.*;
import netP5.*;

Serial myPort;  // Create object from Serial class
int value = 0;
int channel = 0;
int number = 21;
int linefeed = 10;
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() 
{
  size(200, 200);
  println (Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  
  //OSC
  oscP5 = new OscP5("127.0.0.1",9001);
 myRemoteLocation = new NetAddress("192.168.11.86",12000);

}

void draw(){
  OscMessage myMessage = new OscMessage("/presence");
  myMessage.add(value); /* add an int to the osc message */
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
  println(value);
}


void serialEvent(Serial myPort){

  String myString = myPort.readStringUntil(linefeed);
  if(myString != null ){
    myString = trim(myString);
    int [] val = int(split(myString, ','));
    value = constrain(val[0],0,400);
    //value = int(map(value,0,127,127,0));

  }
}




