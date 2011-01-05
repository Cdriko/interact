import hypermedia.video.*;
import java.awt.*;

import themidibus.*;
import oscP5.*;
import netP5.*;
//--------------------------
MidiBus midiOut;

OscP5 oscP5;
NetAddress myRemoteLocation;

//----------------------openCV----
OpenCV Camera;
int tolerance=50;
int numPixels;
int[]live;
int w,hh;
//---------------------------
int numFlaps=8;
Flaps [] flap = new Flaps[numFlaps];
int[] flapsOn=new int[numFlaps];
int[] x;
int[] y;
int[] l= {
  10,10,10,10,10,10,10,10
};
int[] h= {
  80,80,80,80,80,80,80,80
};
int[] num= {
  60,61,62,63,64,65,66,67
};
int[] oscVal = {
  1,0,0,1,1,1,1,0
};
int c=255;

void setup() {
  smooth();
  w=320;
  hh=240;
  size(320, 240);

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);

  //init midi
  midiOut = new MidiBus(this, -1, "Java Sound Synthesizer");

  ///init camera
  Camera=new OpenCV( this );

  Camera.capture(w,hh);
  numPixels=w*hh;



  int az=width/8;
  int dost=10;
  int[]x= {
    10,40,70,110,140,170,210,240
  };
  int[]y= {
    30,30,30,30,30,30,30,30
  };
  for(int i=0;i<numFlaps;i++) {
    flap[i]= new Flaps(x[i],y[i],l[i],h[i],c,num[i],oscVal[i]);
  }
}

void draw() {
  background(125);

  //affiche l'image live
  Camera.read();
  image( Camera.image(),0,0,320, 240 );	 
  Camera.absDiff();
  Camera.threshold(tolerance);


  for(int j=0;j<numFlaps;j++) {
    flap[j].display();
    flapsOn[j]=0;
  }

  //recupere les blobs du mvt detecte
  Blob[] blobs = Camera.blobs( 100, w*hh/3, 7, true );
  //stocke l'image pour le prochain passage
  Camera.remember();


  for( int i=0; i<blobs.length; i++ ) {//parcour les blobs


    // recupere et dessine le rectangle
    Rectangle bounding_rect	= blobs[i].rectangle;    
    stroke(250);
    noFill();    
    rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );


    ///parcours les touches pour voir si on en touche une
    for(int j=0;j<numFlaps;j++) {

      if (flapsOn[j]==0) {//evite d'activer deux fois la meme touche
        if(flap[j].intersect(bounding_rect)) {
          flap[j].action();
          flapsOn[j]=1;
          break;
        }
      }
    }
  }
}




