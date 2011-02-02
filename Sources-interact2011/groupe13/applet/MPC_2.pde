//import nl.tudelft.ti1100a.audio.*;//--lib loopmixer
import hypermedia.video.*;//--lib video open cv
import java.awt.*;//-- lib graphique java pour créer des GUI
import ddf.minim.*;//-- lib son minim
import ddf.minim.effects.*;

int numFlaps=6;//-- nombre de zones de détection
int tolerance=30;//-- sensibilité de la detection
color c= color(255,123,44);//-- couleur des contours des volets
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

void setup() {
  w = 620;
  hh = 540;
  size(620, 540,P3D);//taille de la fenetre

  minim = new Minim(this);//init minim


  Camera=new OpenCV( this );//init camera
  Camera.capture(w,hh);

  flapsOn=new int[numFlaps];//création zones de détection


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
void draw() {

  
  Camera.read();//paramètres de la camera pendant l'utilisation
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
    rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );//--définition paramètres des blobs

    //--parcours les touches pour voir si on en touche une
    for(int j=0;j<numFlaps;j++) {
      
      if (flapsOn[j]==0) {//--evite d'activer deux fois la meme touche
        if(flap[j].intersect(bounding_rect)) {//--déclenchement de l'action lors d'une interaction entre blobs et flaps
          flap[j].action();
          break;
        }
      }
    }
  }

}



void stop()
{
  for(int j=0;j<numFlaps;j++) {
    flap[j].stop();
  }
  minim.stop();
  super.stop();
}
