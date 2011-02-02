import processing.core.*; 
import processing.xml.*; 

import hypermedia.video.*; 
import java.awt.*; 
import ddf.minim.*; 
import ddf.minim.effects.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class MPC_2 extends PApplet {

//import nl.tudelft.ti1100a.audio.*;//--lib loopmixer
//--lib video open cv
//-- lib graphique java pour cr\u00e9er des GUI
//-- lib son minim


int numFlaps=6;//-- nombre de zones de d\u00e9tection
int tolerance=30;//-- sensibilit\u00e9 de la detection
int c= color(255,123,44);//-- couleur des contours des volets
int w, hh;//--dimension de la fenetre d'affichage
int[] flapsOn; 
float m = millis();

boolean t=true;

String[] monFichier = {
  "everybody.aif","feel.aif","enchained.aif", "ou.aif", "trompette.aif", "redemption2.aif"
};




OpenCV Camera;
Minim minim;

Flaps [] flap = new Flaps[numFlaps];

public void setup() {
  w = 620;
  hh = 540;
  size(620, 540,P3D);//taille de la fenetre

  minim = new Minim(this);//init minim


  Camera=new OpenCV( this );//init camera
  Camera.capture(w,hh);

  flapsOn=new int[numFlaps];//cr\u00e9ation zones de d\u00e9tection


  int[] xi= {
    80, 130, 200, 400, 470, 520
  };
  int[] yi= {
    330, 200, 100, 100, 200, 330
  };

  for(int i=0;i<numFlaps;i++) {
    flap[i]= new Flaps(//-- le constructeur des objets "volets" c'est ce qui fait les zones de detection
    xi[i], //-- x de chaque volets 
    yi[i],//-- y de chaque volets 
    40,//-- largeur de chaque volets
    40,//-- hauteur de chaque volets
    c,//-- couleur des volets  
    monFichier[i]);
  }


}
public void draw() {

  
  Camera.read();//param\u00e8tres de la camera pendant l'utilisation
  image( Camera.image(),0,0,620, 540 );	 
  Camera.absDiff();
  Camera.threshold(tolerance);

  //recupere les blobs du mvt detecte
  Blob[] blobs = Camera.blobs( 10, 30, 500, true );
  //stocke l'image pour le prochain passage
  Camera.remember();

  for(int j=0;j<numFlaps;j++) {
    flap[j].display();
    flapsOn[j]=0;
  }

  for( int i=0; i<blobs.length; i++ ) {//--parcours les blobs

    //--recupere et dessine le rectangle
    Rectangle bounding_rect = blobs[i].rectangle;    
    stroke(250);
    noFill();    
    rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );//--d\u00e9finition param\u00e8tres des blobs

    //--parcours les touches pour voir si on en touche une
    for(int j=0;j<numFlaps;j++) {
      
      if (flapsOn[j]==0) {//--evite d'activer deux fois la meme touche
        if(flap[j].intersect(bounding_rect)) {//--d\u00e9clenchement de l'action lors d'une interaction entre blobs et flaps
          flap[j].action();
          break;
        }
      }
    }
  }

}



public void stop()
{
  for(int j=0;j<numFlaps;j++) {
    flap[j].stop();
  }
  minim.stop();
  super.stop();
}
class Flaps {
  AudioSnippet kick;
  Rectangle me;
  int x,y,l,h;
  float noteOk;
  String fichier;
  int c;
 

  Flaps(int xi, int yi, int li, int hi, int ci, String monFichier) {
    x=xi;
    y=yi;
    l=li;
    h=hi;
    c=ci;
    fichier = monFichier;


    kick=minim.loadSnippet(fichier);

    if(monFichier.equals("redemption2.aif")) {
      kick.loop();
    }

    me = new Rectangle(x-(l/2), y-(h/2), l, h);
  }

  public void display() {

    noFill();
    strokeWeight(5);
    stroke(c);
    rect(x-(l/2),y-(h/2),l,h);
  }

  public boolean intersect(Rectangle visitor) {  
    return me.intersects(visitor);
  }

  public void action() {
    
  
    noteOk=0;
    fill(255,0,0);
    stroke(255,0,0);
    ellipse(x,y,50,50);
    
    if(monFichier.equals("redemption2.aif")) {
      if(kick.isPlaying()) {
        kick.pause();
        kick.play();
      }
      else {
        kick.rewind() ;
        kick.play();
      }
    }
    else {//les autres samples non boucle
      kick.rewind() ;
      kick.play();
    }

  }
  
  public void stop() {
    kick.close();
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "MPC_2" });
  }
}
