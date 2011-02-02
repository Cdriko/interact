class Flaps {
  AudioSnippet kick;
  Rectangle me;
  int x,y,l,h;
  float noteOk;
  String fichier;
  color c;
 

  Flaps(int xi, int yi, int li, int hi, color ci, String monFichier) {
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

  void display() {

    noFill();
    strokeWeight(5);
    stroke(c);
    rect(x-(l/2),y-(h/2),l,h);
  }

  boolean intersect(Rectangle visitor) {  
    return me.intersects(visitor);
  }

  void action() {
    
  
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
  
  void stop() {
    kick.close();
  }
}

