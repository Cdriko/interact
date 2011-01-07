class Lecteur {
  AudioPlayer player;
  String fichier;
  char touche;
  boolean press = false;
  boolean toggle  = false;//-------------------------------------------------- booléen pour déclencher ou arreter la lecture
  int timer = 0, num;
  color c;
  float longueur, posStart, posEnd;//----------------------------------------- valeurs pour positionner les spectre audio

  Lecteur(String _fichier, char _touche, int _num) {
    num = _num;
    fichier = _fichier;
    touche = _touche;
    c = color(random(255), random(255), random(255));
    longueur = width/nb;
    posStart = longueur*num;
    posEnd = longueur*(num+1);
    player = minim.loadFile(fichier, 2048);
  }

  void display() {
    if(keyPressed) {//------------------------------------------------------- ici on remplacera par une entrée type arduino, flux...
      if(key == touche) {
        toggle =! toggle;
      }
    }
    
    
    if(toggle) {      
      player.play();
      stroke(c);
      for(int i = 0; i < player.bufferSize() - 1; i++)//--------------------- visualisation
      {
        float x1 = map(i, 0, player.bufferSize(), posStart, posEnd);//width);
        float x2 = map(i+1, 0, player.bufferSize(), posStart, posEnd);//width);
        line(x1, 50 + player.left.get(i)*50, x2, 50 + player.left.get(i+1)*50);
        line(x1, 150 + player.right.get(i)*50, x2, 150 + player.right.get(i+1)*50);
      }
    }

    if(toggle==false) {
      player.pause();
      player.rewind();
    }
  }
}

