// update Nam June Paik Robot family


import processing.serial.*;
import promidi.*;


MidiIO midiIO;
MidiOut midiOut;
Serial myPort;  // Create object from Serial class
int value = 0;
int channel = 0;
int number = 21;
int linefeed = 10;


void setup() 
{
  size(200, 200);
  println (Serial.list());
  String portName = Serial.list()[1];
  midiIO = MidiIO.getInstance(this);
  println("printPorts of midiIO");
  midiIO.printDevices();
  midiOut = midiIO.getMidiOut(0,2);
  myPort = new Serial(this, portName, 9600);

}

void draw(){

  midiOut.sendController(
  new Controller(number,value)
    );
  println(value);
}


void serialEvent(Serial myPort){

  String myString = myPort.readStringUntil(linefeed);
  if(myString != null ){
    myString = trim(myString);
    int [] val = int(split(myString, ','));
    value = constrain(val[0],0,127);
    value = int(map(value,0,127,127,0));

  }
}



