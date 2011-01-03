/*
 * Arduino SpookySounds
 * --------------------
 *
 * Draws a scary eyeball and plays a spooky sound whenever a 
 * number is sent on a serial port. 
 * Press space bar to clear screen.
 * 
 * Receives an ASCII number over the serial port,
 * terminated with a carriage return (ascii 13) then newline (10).
 * Doesn't use the numeric value, but does parse it.
 *
 * This matches what Arduino's "Serial.println(val)" function
 * puts out.
 *
 * Depends on the Ess sound library and 9 sounds in the 
 * data directory named "spooky01.wav" ... "spooky09.wav"
 *
 * Created 25 October 2006
 * copyleft 2006 Tod E. Kurt <tod@todbot.com
 * http://todbot.com/
 */

import processing.serial.*;
import krister.Ess.*;

// Change this to the portname your Arduino board
String portname = "/dev/tty.usbserial-A3000Xv0"; // or "COM5"

Serial port;
String buf="";
int cr = 13;  // ASCII return   == 13
int lf = 10;  // ASCII linefeed == 10

int num_sounds = 9;
AudioChannel myChannel[];

void setup() {
  size(300,300);
  frameRate(10);
  smooth();
  background(40,40,40);
  noStroke();
  port = new Serial(this, portname, 9600);
  Ess.start(this);           // start up Ess sound system

  // load up sounds to play
  myChannel = new AudioChannel[num_sounds];
  for(int i=0; i< num_sounds; i++) {
    myChannel[i] = new AudioChannel("spooky0"+i+".wav");
  }
}

void draw() {
  // all drawing is done in keyPressed or serialEvent
}

void keyPressed() {
  if(key == ' ') {
    background(40,40,40);
  }
  evileye();
}

// called whenever serial data arrives
void serialEvent(Serial p) {
  int c = port.read();
  if(c != lf && c != cr ) {
    buf += char(c);
  }
  if( c == lf ) {         // indicates end of an arduino println()
    int val = int(buf);   // we've got a value, let's use it
    println("val="+val);  // just print it out, not gonana use it
    int x = int(random(0,width));
    int y = int(random(0,height));
    evileye();
    buf = "";             // reset buf
  }
}

void evileye() {
  int r = int(random(num_sounds));
  myChannel[r].play(1);   // play a random sound

  int x = int(random(0,300));
  int y = int(random(0,300));
  fill(240,0,0);
  ellipse(x,y, 50,9);
  fill(30,0,0);
  ellipse(x,y, 8,8);
}


// we are done, clean up Ess
public void stop() {
  Ess.stop();
  super.stop();
}

