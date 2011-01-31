// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

import org.openkinect.*;
import org.openkinect.processing.*;
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;


// Showing how we can farm all the kinect stuff out to a separate class
KinectTracker tracker;
// Kinect Library object
Kinect kinect;

int accelerationP = 8;
int reculerP = 9;
int gaucheP = 6;
int droiteP = 7;

int x_1;
int x_2;
int x_3;
int x_4;

int y_1;
int y_2;
int y_3;
int y_4;



void setup() {
  size(640,520);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  
  
  x_1 = 0;
  x_2 = 213;
  x_3 = 426;
  x_4 = 640;

y_1 = 0;
y_2 = 173; 
y_3 = 346; 
y_4 = 520;

  arduino = new Arduino(this, Arduino.list()[0], 57600);
//arduino = new Serial(this,Serial.list().[0],9600);
  arduino.pinMode(accelerationP, Arduino.OUTPUT);
    arduino.pinMode(reculerP, Arduino.OUTPUT);
      arduino.pinMode(gaucheP, Arduino.OUTPUT);
        arduino.pinMode(droiteP, Arduino.OUTPUT);
  println(Arduino.list()); 

}

void draw() {
  background(255);






  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50,100,250,200);
  noStroke();
  ellipse(v1.x,v1.y,20,20);
  
  if(((v1.x) > x_1 ) && ((v1.x) < x_2 ) && ((v1.y) > y_1 ) && ((v1.y) < y_2 ))
{
 
 arduino.digitalWrite(accelerationP, Arduino.HIGH);
  arduino.digitalWrite(reculerP, Arduino.LOW);
   arduino.digitalWrite(gaucheP, Arduino.HIGH);
    arduino.digitalWrite(droiteP, Arduino.LOW);
   println(accelerationP);
   println(gaucheP);
 
  
  //voiture avance et tourne a gauche
}

 if(((v1.x) > x_1 ) && ((v1.x) < x_2 ) && ((v1.y) > y_2 ) && ((v1.y) < y_3 ))
{
  arduino.digitalWrite(gaucheP, Arduino.HIGH);
   arduino.digitalWrite(accelerationP, Arduino.LOW);
    arduino.digitalWrite(reculerP, Arduino.LOW);
     arduino.digitalWrite(droiteP, Arduino.LOW);
     println(gaucheP);
  //voiture tourne seulement a gauche
}


 if(((v1.x) > x_1 ) && ((v1.x) < x_2 ) && ((v1.y) > y_3 ) && ((v1.y) < y_4 ))
{

 arduino.digitalWrite(gaucheP, Arduino.HIGH);
   arduino.digitalWrite(accelerationP, Arduino.LOW);
    arduino.digitalWrite(reculerP, Arduino.HIGH);
     arduino.digitalWrite(droiteP, Arduino.LOW);
     println(gaucheP);
     println(reculerP);
  //voiture recule en tournant a gauche
}




 if(((v1.x) > x_2 ) && ((v1.x) < x_3 ) && ((v1.y) > y_1 ) && ((v1.y) < y_2 ))
{
    arduino.digitalWrite(gaucheP, Arduino.LOW);
   arduino.digitalWrite(accelerationP, Arduino.HIGH);
    arduino.digitalWrite(reculerP, Arduino.LOW);
     arduino.digitalWrite(droiteP, Arduino.LOW);
     println(accelerationP);
  //voiture avance tout droit
}

 if(((v1.x) > x_2 ) && ((v1.x) < x_3 ) && ((v1.y) > y_2 ) && ((v1.y) < y_3 ))
{
  
   arduino.digitalWrite(gaucheP, Arduino.LOW);
   arduino.digitalWrite(accelerationP, Arduino.LOW);
    arduino.digitalWrite(reculerP, Arduino.LOW);
     arduino.digitalWrite(droiteP, Arduino.LOW);
     
  
  //voiture à l'arret
}

 if(((v1.x) > x_2 ) && ((v1.x) < x_3 ) && ((v1.y) > y_3 ) && ((v1.y) < y_4 ))
{
  arduino.digitalWrite(gaucheP, Arduino.LOW);
   arduino.digitalWrite(accelerationP, Arduino.LOW);
    arduino.digitalWrite(reculerP, Arduino.HIGH);
     arduino.digitalWrite(droiteP, Arduino.LOW);
     println(reculerP);
  //voiture recule en ligne droite
}

 if(((v1.x) > x_3 ) && ((v1.x) < x_4 ) && ((v1.y) > y_1 ) && ((v1.y) < y_2 ))
{
 arduino.digitalWrite(gaucheP, Arduino.LOW);
   arduino.digitalWrite(accelerationP, Arduino.HIGH);
    arduino.digitalWrite(reculerP, Arduino.LOW);
     arduino.digitalWrite(droiteP, Arduino.HIGH);
  //voiture avance vers la droite
}

 if(((v1.x) > x_3 ) && ((v1.x) < x_4 ) && ((v1.y) > y_2 ) && ((v1.y) < y_3 ))
{
  arduino.digitalWrite(gaucheP, Arduino.LOW);
   arduino.digitalWrite(accelerationP, Arduino.LOW);
    arduino.digitalWrite(reculerP, Arduino.LOW);
     arduino.digitalWrite(droiteP, Arduino.HIGH);
     println(droiteP);
  //voiture tourne a droite sans avancer
}

 if(((v1.x) > x_3 ) && ((v1.x) < x_4 ) && ((v1.y) > y_3 ) && ((v1.y) < y_4 ))
{
   arduino.digitalWrite(gaucheP, Arduino.LOW);
   arduino.digitalWrite(accelerationP, Arduino.LOW);
    arduino.digitalWrite(reculerP, Arduino.HIGH);
     arduino.digitalWrite(droiteP, Arduino.HIGH);
     println(reculerP);
     println(droiteP);
  //voiture recule en tournant a droite
}


  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  fill(100,250,50,200);
  noStroke();
  ellipse(-10,v2.y,20,20);

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + (int)frameRate + "    " + "UP increase threshold, DOWN decrease threshold",10,500);
}

void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } 
    else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
}

void stop() {
  tracker.quit();
  super.stop();
}

