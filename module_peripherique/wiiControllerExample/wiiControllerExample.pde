import processing.opengl.*;

import oscP5.*;
import netP5.*;
PImage b;

WiiController wiiController;

void setup() {
  colorMode(RGB,255);
  size(800,600,OPENGL);
  frameRate(25);
  noStroke();
  smooth();
  wiiController = new WiiController();
  background(254,254,78);
  
  b = loadImage("curseur.gif");
  
}

void mousePressed() {
  // check the battery level of the wii controller
  wiiController.oscP5.send("/wii/batterylevel",new Object[] {},"127.0.0.1",5601);
  // turn force feedback of the wii controller off 
  wiiController.oscP5.send("/wii/forcefeedback",new Object[] {new Integer(0)},"127.0.0.1",5601);
}

void keyPressed() {
  // turn forc feedback of the wii controller on
  wiiController.oscP5.send("/wii/forcefeedback",new Object[] {new Integer(1)},"127.0.0.1",5601);
}


void draw() {
 
  if(wiiController.buttonB) {fill(255); } else {fill(255,0,0);}
/*  pushMatrix();
    translate(100,100,0);
    rotateY(wiiController.roll/40.0);
    rotateX(wiiController.roll/40.0);
    rotateX(wiiController.pitch/40.0);
    rect(wiiController.x/4.0,wiiController.y/4.0,10,10);
  popMatrix();
  */
  //line(mouseX,mouseY,67,23);
  
if(wiiController.buttonA){

//rect(wiiController.x/2,wiiController.y/2,32,32);}
//println("roll " +wiiController.roll);
//println("pitch " +wiiController.roll/2);
//println("pitch " +wiiController.acc.y);
println("B " +wiiController.x);
fill(12,14,14,20);
//rect(wiiController.x/2,wiiController.y/2,abs(wiiController.roll/2),abs(wiiController.pitch/2));}
rect(wiiController.x/2,wiiController.y/2,32,32);}

//line(wiiController.x/2,wiiController.y/2,abs(wiiController.roll/2),abs(wiiController.pitch/2));}



 if(wiiController.buttonA == false){
  // keyPressed('a
   //curseur();
   //println("oui");
   }
}
 void curseur(){
   image(b,40,40);
   


}
