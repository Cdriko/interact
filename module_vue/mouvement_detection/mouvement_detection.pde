import hypermedia.video.*;//--------------------------------------------------------------- lib video open cv
import java.awt.*;//----------------------------------------------------------------------- lib graphique java pour créer des GUI
import themidibus.*;//--------------------------------------------------------------------- lib midi
import oscP5.*;//-------------------------------------------------------------------------- lib OSC
import netP5.*;//-------------------------------------------------------------------------- lib réseau internet

int numFlaps=7;//--------------------------------------------------------------------------- on change ici le nombre de volets (adapter la largeur en fonction).
int tolerance=30;//------------------------------------------------------------------------- sensibilité de la detection
color c= color(255,123,44);//---------------------------------------------------------------- couleur des contours des volets
int[] flapsOn=new int[numFlaps];
int w, hh;//-------------------------------------------------------------------------------- pour définir les dimensions de la fenetre d'affichage

OpenCV Camera;
MidiBus midiOut;
OscP5 oscP5;
NetAddress myRemoteLocation;
Flaps [] flap = new Flaps[numFlaps];

void setup() {
  w = 320;
  hh = 240;
  size(320, 240);

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  //init midi
  midiOut = new MidiBus(this, -1, "Java Sound Synthesizer");
  ///init camera
  Camera=new OpenCV( this );
  Camera.capture(w,hh);
  //=+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
  for(int i=0;i<numFlaps;i++) {
    flap[i]= new Flaps(//---------------------------- le constructeur des objets "volets" c'est ce qui fait les zones de detection
    (width/(numFlaps+1))*(i+1), //------------------- x de chaque volets calculé en fonction du nombre de volets et de la taille de la fenetre
    80,//-------------------------------------------- y de chaque volets (valeur valable ici pour tous).
    width/(numFlaps+8),//---------------------------- largeur de caque volets
    70,//-------------------------------------------- hauteur de chaque volets
    c,//--------------------------------------------- couleur des volets
    60+i,//------------------------------------------ note midi envoyée pour chaque volets.
    i//---------------------------------------------- valeur OSC envoyée pour chaque volets
    );
  }
}

void draw() {

  Camera.read();
  image( Camera.image(),0,0,320, 240 );	 
  Camera.absDiff();
  Camera.threshold(tolerance);

  //recupere les blobs du mvt detecte
  Blob[] blobs = Camera.blobs( 10, 30, 5, true );
  //stocke l'image pour le prochain passage
  Camera.remember();

  for(int j=0;j<numFlaps;j++) {
    flap[j].display();
    flapsOn[j]=0;
  }
  for( int i=0; i<blobs.length; i++ ) {//parcour les blobs

    // recupere et dessine le rectangle
    Rectangle bounding_rect = blobs[i].rectangle;    
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

