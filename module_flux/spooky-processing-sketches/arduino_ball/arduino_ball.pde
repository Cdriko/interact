/*
 * Arduino Ball
 * ------------ 
 *
 * Draw balls randomly on the screen, size controlled by a device
 * on a serial port.  Press space bar to clear screen, or any
 * other key to generate fixed-size random balls.
 *
 * Receives an ASCII number over the serial port, 
 * terminated with a carriage return (ascii 13) then newline (10).
 * 
 * This matches what Arduino's "Serial.println(val)" function
 * puts out.
 *
 * Created 25 October 2006
 * copyleft 2006 Tod E. Kurt <tod@todbot.com
 * http://todbot.com/
 */

import processing.serial.*;

// Change this to the portname your Arduino board
String portname = "/dev/tty.usbserial-A3000Xv0"; // or "COM5"

Serial port;
String buf="";
int cr = 13;  // ASCII return   == 13
int lf = 10;  // ASCII linefeed == 10

void setup() {
  size(300,300);
  frameRate(10);
  smooth();
  background(40,40,40);
  noStroke();
  port = new Serial(this, portname, 9600);
}

void draw() {
}

void keyPressed() {
  if(key == ' ') {
    background(40,40,40);  // erase screen
  }
  else {
    int x = int(random(0,width));
    int y = int(random(0,height));
    drawball(x,y, 50);
  }
}

// draw a ball
void drawball(int x, int y, int r) {
  for( int i=0; i<100; i++ ) {
    fill(255-i,i,240);
    ellipse(x,y+i, r,r);
  }
}

// called whenever serial data arrives
void serialEvent(Serial p) {
  char c = port.readChar();
  if( c == '!' ) {
    // do something A
  } else if( c == '@' ) {
    // do something B
  }
  int x = int(random(0,width));
  int y = int(random(0,height));
  drawball(x,y, 50);
}
