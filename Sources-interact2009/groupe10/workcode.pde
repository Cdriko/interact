import hypermedia.video.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;
OpenCV opencv;

PFont font;

float volume;
float seuil=26.0;
float moyenne=0;

int depart = 0;
boolean facepresente = false;
boolean detect = true;

int departSon = 0;
boolean sonner = true;

void setup() {
  size(640,480);
  frameRate(20);
  minim = new Minim(this);
  minim.debugOn();

  in = minim.getLineIn(Minim.STEREO, 16);
  fft = new FFT(in.bufferSize(), in.sampleRate());

  opencv = new OpenCV( this );
  opencv.capture( 320, 240);                   // open video stream
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"

  noStroke();
}

void draw() {
  background(0);

  // moyenne de l'entrée dans le buffer
  volume=0;
  for(int i = 0; i < in.bufferSize() - 1; i++) {
    volume += abs(in.left.get(i))*10;
  }
  // moyenne sur 10 frames
  moyenne=((moyenne *9) + volume)/10;


  if (volume > seuil && sonner) {
    link("http://turing.lecolededesign.com/nraad/salleslibres");
    sonner = false;
    departSon = millis();
  }

  if (millis()-departSon > 33000) {
    sonner=true;
  }

  fill(255);
  line(0,height/2,width,height/2);

  // dessiner le volume
  fill(26,209,249);
  noStroke();
  rect(0,height-map(volume,0,seuil*2,0,height*2),width,map(volume,0,seuil*2,0,height*2));

  //////////////////  //////////////////  //////////////////

  // grab a new frame
  opencv.read();

  // proceed detection
  Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );

  // display the image
  image( opencv.image(), 0, 0 );

  if (faces.length>0 && detect) {
    if (facepresente) {
      if (millis()-depart > 3000) {
        link("http://turing.lecolededesign.com/nraad/salleslibres");
        detect=false;
        facepresente=false;
      }
    }
    else {
      depart = millis();
      facepresente = true;
    }
  }

  if (millis()-depart > 33000) {
    detect=true;
  }

  // draw face area(s)
  noFill();
  stroke(26,209,249);
  strokeWeight(7);
  for( int i=0; i<faces.length; i++ ) {
    rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
  }
}

/////////////////////////////////////

void stop() {
  // always close Minim audio classes when you are done with them
  in.close();
  minim.stop();
  super.stop();
}
