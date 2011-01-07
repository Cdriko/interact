
import ddf.minim.*;
int nb = 5;//------------------------------------------------------------------------ nb de lecteur.
Minim minim;
Lecteur lec[] = new Lecteur[nb];
String [] monFichier = {
  "Sonic_Youth.mp3","RLBurnside.mp3","Candie-Hank.mp3","BBoys.mp3","aphex_twin.mp3"
};
char[] maTouche = {//--------------------------------------------------------------- mes touches de déclenchements qui pourront etre remplacer par un autre type d'entrée
  'a', 'z', 'e', 'r', 't'
};

void setup()
{
  size(600, 200, P3D);
  minim = new Minim(this);
  for(int i=0; i<lec.length; i++) {
    int num = i;
    lec[i] = new Lecteur(monFichier[i], maTouche[i], num);//----------------------- je crée mes lecteurs
  }
}

void draw()
{
  background(0);
  stroke(255);
  for(int i=0; i<lec.length; i++) {
    lec[i].display();
  }
}

void stop()
{

  for(int i=0; i<lec.length; i++) {
    lec[i].player.close();
  }
  minim.stop();
  super.stop();
}

