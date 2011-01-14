import ddf.minim.*;
import ddf.minim.signals.*;
import controlP5.*;

ControlP5 controlP5;
Minim minim;

int nb = 5;//------------------------------------------------------------------------------ nombre d'oscillateurs
Slider2D [] s = new Slider2D[nb];//-------------------------------------------------------- tableau de slider2d
SineWave [] sine = new SineWave[nb];//----------------------------------------------------- tableau d'oscillateurs
AudioOutput out;//------------------------------------------------------------------------- sortie audio générale

float [] freq = new float[nb];//----------------------------------------------------------- frequences pour chaque oscillateur
float vol [] = new float[nb];//------------------------------------------------------------ volume pour chaque oscillateur

void setup()
{
  size(800, 400);
  smooth();

  controlP5 = new ControlP5(this);//--------------------------------------------------------- on crée une instance controP5
  minim = new Minim(this);//----------------------------------------------------------------- idem pour minim

  //----------------------------------------------------------------------------------------- on crée une sortie stereo, 
  //----------------------------------------------------------------------------------------- avec un buffer de 1024 (mémoire tampon)
  //----------------------------------------------------------------------------------------- a une fréquence de 22000 Hz et 16 bits
  out = minim.getLineOut(Minim.STEREO, 1024, 22000, 16);

  for(int i=0; i<s.length; i++) {
    //----------------------------------------------------------------------------------------- on crée une onde sinusoidale à 440 hz (le LA du tel)
    sine[i] = new SineWave(440, 0.5, out.sampleRate());
    //----------------------------------------------------------------------------------------- on crée un portamento est un glissement d'une note à une autre
    sine[i].portamento(200);
    //----------------------------------------------------------------------------------------- on ajoute la forme d'onde à la sortie
    out.addSignal(sine[i]);
    //----------------------------------------------------------------------------------------- mise en place des sliders2D
    String name = "sinusoide_"+(i+1);//-------------------------------------------------------- leur nom
    int h = width/(nb+5);//-------------------------------------------------------------------- leur taille
    int x = ((width/nb)*i) + h/2;//------------------------------------------------------------ leur position abscisse 
    int y = (height/16);//--------------------------------------------------------------------- leur position ordonnée
    s[i] = controlP5.addSlider2D(name, x, y, h, h);//------------------------------------------ on crée autant de sliders qu'il y a d'oscillateurs
    s[i].setArrayValue(new float[] {//--------------------------------------------------------- pour initialiser la valeur du slider
      0, width/(nb+5)
    }
    );
    color c = color(0,0,0);
    s[i].setColorBackground(c);
    s[i].setColorValue(c);
    s[i].setColorLabel(c);
    //s[i].setLabelVisible(false);
  }
}

void draw()
{
  background(255,124,242);
  fill(124,255,170);
  rect(0,0,width,height/3);
  stroke(0);
  //------------------------------------------------------------------------------------------  on visualise la forme d'onde du signal de sortie
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    line(x1, (height/2+30) + out.left.get(i)*50, x2, (height/2+30) + out.left.get(i+1)*50);
    line(x1, (height/2+130) + out.right.get(i)*50, x2, (height/2+130) + out.right.get(i+1)*50);
  }
  //------------------------------------------------------------------------------------------ on réévalue les fréquences et volumes des oscillateurs
  //------------------------------------------------------------------------------------------ à partir des valeurs des sliders 2d
  for(int i=0; i<nb; i++) {
    freq[i] = map(s[i].arrayValue()[0], 0, width/(nb+5), 60, 1500);
    vol[i] = map(s[i].arrayValue()[1], 0, width/(nb+5), 0.5, 0);
    sine[i].setFreq(freq[i]);
    sine[i].setAmp(vol[i]);
  }
}

void stop()
{
  out.close();
  minim.stop();

  super.stop();
}

