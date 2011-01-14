import oscP5.*;
import netP5.*;
import processing.serial.*;

int count = 2;
int linefeed = 10;
int [] sensors = new int[count];
int [] transmit = new int[count];
boolean [] play = new boolean[count];
PImage bab;
PImage bob;
Serial myPort;
OscP5 oscP5;
NetAddress myRemoteLocation;



void setup(){
  size(400,400);

  println(Serial.list());

  bab = loadImage("ok.JPG");
  bob = loadImage("ik.JPG");
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil(linefeed);

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("192.168.11.86", 12000);

  for(int i = 0 ; i<count;i++){
    transmit[i] = 1;
    play[i] = false;

  }


}
void draw(){
  background(0);
  OscMessage myMessage = new OscMessage("/test");

  for(int i = 0 ; i < count ; i++){
    if(play[i]){
     transmit[i]++;
     }
    else{
      transmit[i]=0;
    }
  }
  myMessage.add(transmit[0]);
  myMessage.add(transmit[1]);
  //println(transmit[0] + " et " + transmit[1]);
  //println(myMessage);
  oscP5.send(myMessage, myRemoteLocation); 

}

void serialEvent(Serial myPort){


  String myString = myPort.readStringUntil(linefeed);

  if(myString != null ){
    myString = trim(myString);
    int [] trad = int(split(myString, ','));
    if(trad.length == count){
      sensors = trad;
    }
    /*for(int sensorNum = 0; sensorNum < sensors.length; sensorNum++){
     print("sensor " + sensorNum + " : " + sensors[sensorNum] + "\t");
     }*/
    for(int i = 0; i < count; i++){
      if(sensors[i]==1){
        play[i] =true;

      }
      else{
        play[i] = false;

      }
    }


    //println();
  }
  //println(play[0]);
}




























