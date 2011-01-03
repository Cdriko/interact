///////////////------------
//
//
//
//
//
////////////////------------




import JMyron.*;

//----------------> un objet camera
JMyron m;
PImage my;


int R,B,G;
float easing = 0.05;//smoothing des deplacements
float x=0.0;
float y=0.0;

void setup()
{
  size(320, 240);
  my = loadImage("my.jpeg");
  imageMode(CENTER);
  
  m = new JMyron();//make a new instance of the object
  m.start(width,height);//start a capture at 320x240
  m.findGlobs(1);//disable the intelligence to speed up frame rate
  println("Myron " + m.version());
  m.trackColor(255,0,0,205);
  m.minDensity(25);



}

void draw()
{
  //-------------> on rafraichi la camera
  m.update();//update the camera view
  //-------------> on récupère la vue des globs détecter par rapport à la méthode trackColor()
  //int[] img = m.globsImage(); 
  //-------------> on récupere l'image normale de la cam
  int[] img = m.image();
  //----------> on récupere les coordonnées du centre des blobs
  int[][][] b = m.globPixels();
  //----------> on charge les pixels de l'image de la cam
  loadPixels();
  //------------> on copie les pixels de la cam vers l'affichage de la fenetre processing
  arraycopy(img,pixels);
  //----------> on mets à jour.
  updatePixels();

  //-------------> manque de précision mais permet de choisir la couleur de détection en fonction du pointeur de la souris
  //m.trackColor(R,G,B,105);

  //--------------> on boucle au travers de b
  for(int i=0;i<b.length;i++){
    // -----------> en fonction de l'emplacement du centre de la couleur détectée on assigne une variable pour chaque coordonnées
    float targetX =b[0][0][0];
    float targetY =b[0][0][1];
    float disX=targetX-x;
    float disY=targetY-y;
    //------------> on callcul un ralentissement
    x+=disX*easing;
    y+=disY*easing;
    //------------> on affiche l'image à l'emplacement de la couleur detectée
    image(my,x,y);
  }
}

void mousePressed() {
  //--------> on capture la valeur de la couuleur à l'emplacement du pointeur
  /*int loc = mouseX + mouseY*width;
   trackColor = pixels[loc];*/
  //-------> ou
  color trackColor = get(mouseX,mouseY);

  //-----------> on extrait les paramètres de color en int
  /* R = (trackColor >> 24) & 0xFF;
   G = (trackColor >> 16) & 0xFF;  // Faster way of getting red(argb)
   B = (trackColor >> 8) & 0xFF; */
  //--------> ou
  R = int(red(trackColor));
  G = int(green(trackColor));
  B = int(blue(trackColor));

  println("r = " + R +" g = " + G + " b = " + B );
}

void keyPressed(){
  if(key == 's' || key == 'S'){
    m.settings();//click the window to get the settings
  }
}








