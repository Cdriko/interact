import hypermedia.video.*;
import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput out;
SineWave son1;
SineWave son2;
SineWave son3;
SineWave son4;

OpenCV opencv;
PImage maSource;

color trackColor1;
color trackColor2;
color trackColor3;
color trackColor4;

int nbPixels;

float easing = 0.05;//----------------------------------------------- variable pour le ralentissement des déplacements de ellipses
float xA = 0.0;
float yA = 0.0;
float xZ = 0.0;
float yZ = 0.0;
float xE = 0.0;
float yE = 0.0;
float xR = 0.0;
float yR = 0.0;

float diffNess = 20;//----------------------------------------------- la valeur de référence en dessus de laquelle il ne se passe rien

//taille de la camera
int rcamW=640;
int rcamH=480;

//retour video ou non
boolean retourVideo=true;
boolean startTrack1 = false;
boolean startTrack2 = false;
boolean startTrack3 = false;
boolean startTrack4 = false;
boolean traces = false;

void setup()
{
  size(rcamW, rcamH, P2D);

  nbPixels = width * height;//--------------------------------------- nombre de pixels total.  
  //----------------------------------------------------------------- on accède à la caméra
  opencv = new OpenCV( this );



  opencv.capture( width, height ); 
  maSource = new PImage( width, height);
  smooth();

  minim = new Minim(this);
  // get a line out from Minim, default bufferSize is 1024, default sample rate is 44100, bit depth is 16
  out = minim.getLineOut(Minim.STEREO);
  // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
  son1 = new SineWave(440, 0.5, out.sampleRate());
  son2 = new SineWave(440, 0.5, out.sampleRate());
  son3 = new SineWave(440, 0.5, out.sampleRate());
  son4 = new SineWave(440, 0.5, out.sampleRate());
  // set the portamento speed on the oscillator to 200 milliseconds
  son1.portamento(200);
  son2.portamento(200);
  son3.portamento(200);
  son4.portamento(200);
  // add the oscillator to the line out
  out.addSignal(son1);
  out.addSignal(son2);
  out.addSignal(son3);
  out.addSignal(son4);

  background(0);
}

void draw()
{
  if(traces) {
    fill(0,10);
    rect(0,0,width,height);
  }
  stroke(255);
  //  // draw the waveforms
  //  for(int i = 0; i < out.bufferSize() - 1; i++)
  //  {
  //    float x1 = map(i, 0, out.bufferSize(), 0, width);
  //    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
  //    line(x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50); 
  //    line(x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  //  }
  opencv.read();



  if(retourVideo) {
    image(maSource, 0, 0, width, height);
  }


  int[]live = opencv.image().pixels;
  maSource.loadPixels();

  float trackX=0, trackY=0;
  float trackX2=0, trackY2=0;
  float trackX3=0, trackY3=0;
  float trackX4=0, trackY4=0;
  float diffColor, diffColor2, diffColor3, diffColor4;

  boolean Adetecte=false;
  boolean Zdetecte=false;
  boolean Edetecte=false;
  boolean Rdetecte=false;


  for(int loc=0; loc<nbPixels; loc++) {
    maSource.pixels[loc]=live[loc];//--------------------------------------- on passe en revue chaque pixel 

    color currentcolor = live[loc];//--------------------------------------- on mémorise la couleur des pixels
    //---------------------------------------------------------------------- couleur actuelle
    float rCurrent = (currentcolor >> 16) & 0xFF;
    float gCurrent = (currentcolor >> 8) & 0xFF;   
    float bCurrent = currentcolor & 0xFF;
    //---------------------------------------------------------------------- valeurs de la couleur recherchée n°1
    float rA = (trackColor1 >> 16) & 0xFF;
    float gA = (trackColor1 >> 8) & 0xFF;   
    float bA = trackColor1 & 0xFF;
    //---------------------------------------------------------------------- valeurs de la couleur recherchée n°2
    float rZ = (trackColor2 >> 16) & 0xFF;
    float gZ = (trackColor2 >> 8) & 0xFF;   
    float bZ = trackColor2 & 0xFF;
    //---------------------------------------------------------------------- valeurs de la couleur recherchée n°3
    float rE = (trackColor3 >> 16) & 0xFF;
    float gE = (trackColor3 >> 8) & 0xFF;   
    float bE = trackColor3 & 0xFF;
    //---------------------------------------------------------------------- valeurs de la couleur recherchée n°4
    float rR = (trackColor4 >> 16) & 0xFF;
    float gR = (trackColor4>> 8) & 0xFF;   
    float bR = trackColor4 & 0xFF;
    //---------------------------------------------------------------------- différence entre la couleur actuelle et celle recherchée n°1
    float diffR = abs(rCurrent - rA);
    float diffG = abs(gCurrent - gA);
    float diffB = abs(bCurrent - bA);
    //---------------------------------------------------------------------- différence entre la couleur actuelle et celle recherchée n°2
    float diffR2 = abs(rCurrent - rZ);
    float diffG2 = abs(gCurrent - gZ);
    float diffB2 = abs(bCurrent - bZ);
    //---------------------------------------------------------------------- différence entre la couleur actuelle et celle recherchée n°3
    float diffR3 = abs(rCurrent - rE);
    float diffG3 = abs(gCurrent - gE);
    float diffB3 = abs(bCurrent - bE);
    //---------------------------------------------------------------------- différence entre la couleur actuelle et celle recherchée n°4
    float diffR4 = abs(rCurrent - rR);
    float diffG4 = abs(gCurrent - gR);
    float diffB4 = abs(bCurrent - bR);
    //---------------------------------------------------------------------- on additionne les différences
    diffColor = diffR + diffG + diffB;
    diffColor2 = diffR2 + diffG2 + diffB2;
    diffColor3 = diffR3 + diffG3 + diffB3;
    diffColor4 = diffR4 + diffG4 + diffB4;
    //---------------------------------------------------------------------- si la diffèrence est inférieure à la diffNess
  if(diffColor < diffNess && startTrack1) {
      ///la couleur est trouvee
      trackX = loc%maSource.width;
      trackY = loc/maSource.width+1;
      xA+=(trackX-xA)*easing;
      yA+=(trackY-yA)*easing;
      Adetecte=true;
    }

    if(diffColor2 < diffNess && startTrack2) {
      trackX2 = loc%maSource.width;
      trackY2 = loc/maSource.width+1;
      xZ+=(trackX2-xZ)*easing;
      yZ+=(trackY2-yZ)*easing;
      Zdetecte=true;
    }

    if(diffColor3 < diffNess && startTrack3) {
      trackX3 = loc%maSource.width;
      trackY3 = loc/maSource.width+1;
      xE+=(trackX3-xE)*easing;
      yE+=(trackY3-yE)*easing;
      Edetecte=true;
    }


    if(diffColor4 < diffNess && startTrack4) {
      trackX4 = loc%maSource.width;
      trackY4 = loc/maSource.width+1;
      xR+=(trackX4-xR)*easing;
      yR+=(trackY4-yR)*easing;
      Rdetecte=true;
    }
  }

  //fin du parcour de tous les pixels
  maSource.updatePixels();

  /////////////////////////1
  if(Adetecte) {
    float freq1 = map(xA, 0, width, 60,220);
    son1.setFreq(freq1);
    float volume1 = map(yA,0,height,0,0.6);
    son1.setAmp(volume1);
  }
  else {
    son1.setAmp(0);
  }
  /////////////////////////2
  if(Zdetecte) {
    float freq2 = map(xZ, 0, width, 600,1200);
    son2.setFreq(freq2);
    float volume2 = map(yZ,0,height,0,0.6);
    son2.setAmp(volume2);
  }
  else {
    son2.setAmp(0);
  }
  /////////////////////////3
  if(Edetecte) {
    float freq3 = map(xE, 0, width, 220,400);
    son3.setFreq(freq3);
    float volume3 = map(yE,0,height,0,0.6);
    son3.setAmp(volume3);
  }
  else {
    son3.setAmp(0);
  }
  /////////////////////////4
  if(Rdetecte) {
    float freq4 = map(xR, 0, width, 30,140);
    son4.setFreq(freq4);
    float volume4 = map(yR,0,height,0.6,0);
    son4.setAmp(volume4);
  }
  else {
    son4.setAmp(0);
  }


  ///dessin

  noStroke();
  fill(93, 8,10,155);
  ellipse(xA, yA, 60, 60);
  fill(0,21,91,155);
  ellipse(xZ, yZ, 60, 60);
  fill(255,227,45, 155);
  ellipse(xE, yE, 60, 60);
  fill(35,149,11,155);
  ellipse(xR, yR, 60, 60);


  //exemple
  noFill();
  ellipse(mouseX, mouseY, 20, 20);



  //--------------------------------------------------------------------------- permet de cibler les couleurs recherchées avec le pointeur de
  //--------------------------------------------------------------------------- la souris
  if(keyPressed) {
    if(key == 'A' || key == 'a') {
      int loc = mouseX + mouseY*maSource.width;
      trackColor1 = maSource.pixels[loc];
      startTrack1 = true;
    }
    if(key == 'Z' || key == 'z') {
      int loc = mouseX + mouseY*maSource.width;
      trackColor2 = maSource.pixels[loc];
      startTrack2 = true;
    }
    if(key == 'E' || key == 'e') {
      int loc = mouseX + mouseY*maSource.width;
      trackColor3 = maSource.pixels[loc];
      startTrack3 = true;
    }
    if(key == 'R' || key == 'r') {
      int loc = mouseX + mouseY*maSource.width;
      trackColor4 = maSource.pixels[loc];
      startTrack4 = true;
    }
    if(key=='c') {
      retourVideo = !retourVideo;
      if(!retourVideo) {
        background(0);
        traces = true;
      }
      else {
        traces=false;
      }
    }
  }
}


void stop()
{
  opencv.stop();
  super.stop();
  out.close();
  minim.stop();
  super.stop();
}

