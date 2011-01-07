import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioInput in;
FFT fft;

float volMax;//------------------------------------------- frequence maximale du spectre (une partie de l'algo minmax)
float vert = 0;//----------------------------------------- valeur de vert
float x, y, rayon;

void setup()
{
  size(512, 200, P3D);
  smooth();
  noStroke();
  x=width/2;
  y=height/2;
  rayon = 15;

  minim = new Minim(this);//----------------------------- on crée une instance de Minim
  minim.debugOn();//------------------------------------- active l'affichage du débuggage.
  in = minim.getLineIn(Minim.STEREO, 2048);//------------ on récupère une entrée ligne avec minim, on précise la taille du buffer
  fft = new FFT(in.bufferSize(), in.sampleRate());//----- on crée un objet FFt avec la meme taille et meme sampleRate que in
}

void draw()
{
  background(255);

  fft.forward(in.mix);//--------------------------------- active le fft sur le buffer du in
  volMax=fft.getBand(0);//------------------------------- l'amplitude sur la bande 0 pour initialiser le volume à chaque rafraichissement du prog
  for(int i = 0; i < fft.specSize(); i++)
  {

    if(fft.getBand(i)>volMax)volMax=fft.getBand(i);//---- on cherche le volume maximum du spectre
    if(volMax>13) {//------------------------------------ passé un certains seuil le cercle s'agrandit et devient vert
      vert+=volMax*0.000051f;//---------------------------- la couleur change en fonction de la dynamque du volume
      rayon+=volMax*0.000051f;
    }
    else {
      vert-=0.0004f;
      rayon-=0.0015f;
    }
  }
  vert = constrain(vert, 0, 255);
  rayon = constrain(rayon, 15, height/2);
  fill(0, vert, 0,125);
  lights();
  translate(x, y);
  sphereDetail(35);
  sphere(rayon);
}

void stop()
{
  minim.stop();
  super.stop();
}

