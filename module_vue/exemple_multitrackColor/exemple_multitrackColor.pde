import hypermedia.video.*;

OpenCV opencv;
PImage maSource;

color trackColor1;
color trackColor2;

int nbPixels;

float easing = 0.05;//----------------------------------------------- variable pour le ralentissement des déplacements de ellipses
float xR = 0.0;
float yR = 0.0;
float xB = 0.0;
float yB = 0.0;

float diffNess = 20;//----------------------------------------------- la valeur de référence en dessus de laquelle il ne se passe rien

void setup() {
  size(320, 240); // Change size to 320 x 240 if too slow at 640 x 480
  nbPixels = width * height;//--------------------------------------- nombre de pixels total.  
  //----------------------------------------------------------------- on accède à la caméra
  opencv = new OpenCV( this );
  opencv.capture( width, height ); 
  maSource = new PImage(width, height);
  noStroke();
  smooth();
}

public void stop() {//----------------------------------------------- ferme l'accès à openCV lors de chaque interruption du sketch
  opencv.stop();
  super.stop();
}

void draw() {
  opencv.read();
  image(maSource, 0, 0, width, height);
  int[]live = opencv.image().pixels;
  maSource.loadPixels();

  float trackX=0, trackY=0;
  float trackX2=0, trackY2=0;
  float diffColor, diffColor2;

  for(int loc=0; loc<nbPixels; loc++) {
    maSource.pixels[loc]=live[loc];//--------------------------------------- on passe en revue chaque pixel 

    color currentcolor = live[loc];//--------------------------------------- on mémorise la couleur des pixels
    //---------------------------------------------------------------------- couleur actuelle
    float rCurrent = (currentcolor >> 16) & 0xFF;
    float gCurrent = (currentcolor >> 8) & 0xFF;   
    float bCurrent = currentcolor & 0xFF;
    //---------------------------------------------------------------------- valeurs de la couleur recherchée n°1
    float rR = (trackColor1 >> 16) & 0xFF;
    float gR = (trackColor1 >> 8) & 0xFF;   
    float bR = trackColor1 & 0xFF;
    //---------------------------------------------------------------------- valeurs de la couleur recherchée n°2
    float rB = (trackColor2 >> 16) & 0xFF;
    float gB = (trackColor2 >> 8) & 0xFF;   
    float bB = trackColor2 & 0xFF;
    //---------------------------------------------------------------------- différence entre la couleur actuelle et celle recherchée n°1
    float diffR = abs(rCurrent - rR);
    float diffG = abs(gCurrent - gR);
    float diffB = abs(bCurrent - bR);
    //---------------------------------------------------------------------- différence entre la couleur actuelle et celle recherchée n°2
    float diffR2 = abs(rCurrent - rB);
    float diffG2 = abs(gCurrent - gB);
    float diffB2 = abs(bCurrent - bB);
    //---------------------------------------------------------------------- on additionne les différences
    diffColor = diffR + diffG + diffB;
    diffColor2 = diffR2 + diffG2 + diffB2;
    //---------------------------------------------------------------------- si la diffèrence est inférieure à la diffNess
    if(diffColor < diffNess) {
      trackX = loc%maSource.width;
      trackY = loc/maSource.width+1;
      xR+=(trackX-xR)*easing;
      yR+=(trackY-yR)*easing;
    }
    if(diffColor2 < diffNess) {
      trackX2 = loc%maSource.width;
      trackY2 = loc/maSource.width+1;
      xB+=(trackX2-xB)*easing;
      yB+=(trackY2-yB)*easing;
    }
  }

  maSource.updatePixels();
  fill(0,134);
  ellipse(xR, yR, 20, 20);
  fill(255,0,0,155);
  ellipse(xB, yB, 15, 15);
  //--------------------------------------------------------------------------- permet de cibler les couleurs recherchées avec le pointeur de
  //--------------------------------------------------------------------------- la souris
  if(keyPressed) {
    if(key == 'R' || key == 'r') {
      int loc = mouseX + mouseY*maSource.width;
      trackColor1 = maSource.pixels[loc];
    }
    if(key == 'B' || key == 'b') {
      int loc = mouseX + mouseY*maSource.width;
      trackColor2 = maSource.pixels[loc];
    }
  }
}

