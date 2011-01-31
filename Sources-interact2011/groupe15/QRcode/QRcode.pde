//GNU GENERAL PUBLIC LICENSE
//Version 3, 29 June 2007
//Copyright Â© 2007 Free Software Foundation, Inc. <http://fsf.org/>
//Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.


import codeanticode.gsvideo.*;
import pqrcode.*;
String monAdd = "";
boolean decodeQR = false;
int compteur = 0;

//String mesAdresses= "http://arduino.cc/en/Main/Buy";
String [] mesAdresses ={"http://bit.ly/eYWTmR","http://bit.ly/eJtAMY","http://bit.ly/fhJcgz","http://bit.ly/fhj9Tm","http://bit.ly/1gU39n","http://bit.ly/eRkigm","http://bit.ly/bvshWw","http://sedevacantisme.wordpress.com/2011/01/01/365-pesticides-dans-les-fruits-et-legumes/"};
/*
 QRcode reader
 Generate images from a QRcode generator such as
 http://qrcode.kaywa.com/ and put them in this sketch's
 data folder.
 Press spacebar to read from the camera, generate an image,
 and scan for barcodes.  Press f to read from a file and scan.
 Press s for camera settings.
 Created 9 June 2007
 by Tom Igoe / Daniel Shiffman
 */
GSCapture cam;
String statusMsg = "Presentez un QrCode";     // a string to return messages:
// Decoder object from prdecoder library
Decoder decoder;

void setup() {
  size(320, 240);
  String[] cameras = GSCapture.list();
  if (cameras.length == 0)
  {
    println("There are no cameras available for capture.");
    exit();
 } 
  else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++)
      println(cameras[i]);
    cam = new GSCapture(this, 320, 240, cameras[0]);
  }

  // Create a decoder object
  decoder = new Decoder(this);

  // Create a font with the second font available to the system:
  PFont myFont = createFont(PFont.list()[2], 14);
  textFont(myFont);
}

// When the decoder object finishes
// this method will be invoked.
void decoderEvent(Decoder decoder) {
  statusMsg = decoder.getDecodedString();
for(int i=0; i<mesAdresses.length; i++){
  if(statusMsg.equals(mesAdresses[i])) {
    println("merde");
    link(mesAdresses[i]);
  }}
  //if(statusMsg.equals
}


void draw() {
  background(0);
  if (cam.available() == true) {
    cam.read();
  }
  // Display video
  image(cam, 0, 0);
  // Display status
  text(statusMsg, 10, height-4);
  //ajout
  // if(statusMsg != null)  link(statusMsg); 

  // If we are currently decoding
  if (decoder.decoding()) {

    // Display the image being decoded
    PImage show = decoder.getImage();
    image(show,0,0,show.width/4,show.height/4); 
    statusMsg = "Decoding image";
    //for (int i = 0; i < (frameCount/2) % 10; i++) statusMsg += ".";
  }
  /* if(compteur <2 && statusMsg != null && decodeQR && !(statusMsg.equals("Decoding image")) && !(statusMsg.equals("NO QRcode image found"))  && !(statusMsg.equals("Error: Give up decoding")) && !(statusMsg.equals("Error: Invalid number of Finder Pattern detected"))) {
   println(statusMsg);
   compteur++;
   }*/
}

void keyReleased() {
  String code = "";
  // Depending on which key is hit, do different things:
  switch (key) {
  case ' ':        // Spacebar takes a picture and tests it:
    // copy it to the PImage savedFrame:
    PImage savedFrame = createImage(cam.width,cam.height,RGB);
    savedFrame.copy(cam, 0,0,cam.width,cam.height,0,0,cam.width,cam.height);
    savedFrame.updatePixels();
    // Decode savedFrame
    decoder.decodeImage(savedFrame);
    decodeQR = true;
    break;
  case 'f':    // f runs a test on a file
    PImage preservedFrame = loadImage("qrcode.png");
    // Decode file
    decoder.decodeImage(preservedFrame);
    break;
  case 's':      // s opens the settings page for this capture device:
    //cam.settings();
    break;
  }
}

