/**
 * Brightness Tracking 
 * by Golan Levin. 
 *
 * GSVideo version by Andres Colubri.  
 * 
 * Tracks the brightest pixel in a live video signal. 
 */


import codeanticode.gsvideo.*;

GSCapture video;

color trackRed;
color trackBlue;

float easing = 0.05;
float xR = 0.0;
float yR = 0.0;
float xb = 0.0;
float yb = 0.0;

float worldRecordR = 500;
float worldRecordB = 500;

void setup() {
  size(320, 240); // Change size to 320 x 240 if too slow at 640 x 480
  // Uses the default video input, see the reference if this causes an error
  video = new GSCapture(this, width, height, 30);
  trackRed = color(255,0,0);
  trackBlue = color(0,0,255);
  noStroke();
  smooth();
}

void draw() {
  if (video.available()) {
    video.read();
  }
  video.loadPixels();
  image(video, 0, 0, width, height); // Draw the webcam video onto the screen



  //int xR = 0;
  int xB = 0;
  //int yR = 0;
  int yB = 0;


  //int index = 0;
  for (int y = 0; y < video.height; y++) {
    for (int x = 0; x < video.width; x++) {
      int loc = x + y*video.width;

      color currentcolor = video.pixels[loc];

      float rCurrent = (currentcolor >> 16) & 0xFF;
      float gCurrent = (currentcolor >> 8) & 0xFF;   
      float bCurrent = currentcolor & 0xFF;
      float rR = (trackRed >> 16) & 0xFF;
      float gR = (trackRed >> 8) & 0xFF;   
      float bR = trackRed & 0xFF;
      float rB = (trackBlue >> 16) & 0xFF;
      float gB = (trackBlue >> 8) & 0xFF;   
      float bB = trackBlue & 0xFF;

      float dR = abs(dist(rCurrent,gCurrent,bCurrent,rR,gR,bR));
      //      float dR = abs(dist(rR,gR,bR,rCurrent,gCurrent,bCurrent));
      float dB = dist(rCurrent,gCurrent,bCurrent,rB,gB,bB);

      if (dR < worldRecordR) {
        worldRecordR = dR;
        /*        float tXr = x;
         float tYr = y;
         float disXR = tXr - xR;
         float disYR = tYr - yR;
         xR += disXR * easing;
         yR += disYR * easing;*/
        //        println(dR);
        xR = x;
        yR = y;
      }
      if (dB < worldRecordB) {
        worldRecordB = dB;
        xB = x;
        yB = y;
      }
      //      println(rR+"  "+bR+"  "+gR);
      println(dR);
    }
  }
  if(worldRecordR < 40) {
    fill(trackRed);
    strokeWeight(2);
    stroke(0);
    ellipse(xR,yR,16,16);
  }
  if(worldRecordB < 80) {
    fill(trackBlue);
    strokeWeight(2);
    stroke(0);
    ellipse(xB,yB,16,16);
  }

  //  println(worldRecordR);
  println(red(trackRed)+"  " + blue(trackRed) + "  " + green(trackRed)+ " worldRecordR"+  worldRecordR);
  //println("ok");
  if(keyPressed) {
    if(key == 'R' || key == 'r') {
      int loc = mouseX + mouseY*video.width;
      trackRed = video.pixels[loc];
    }
    if(key == 'B' || key == 'b') {
      int loc = mouseX + mouseY*video.width;
      trackBlue = video.pixels[loc];
    }
  }
}
















