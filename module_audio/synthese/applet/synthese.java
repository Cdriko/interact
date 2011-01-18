import processing.core.*; 
import processing.xml.*; 

import ddf.minim.*; 
import ddf.minim.signals.*; 
import controlP5.*; 

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

public class synthese extends PApplet {





ControlP5 controlP5;
Minim minim;

int nb = 5;//------------------------------------------------------------------------------ nombre d'oscillateurs
Slider2D [] s = new Slider2D[nb];//-------------------------------------------------------- tableau de slider2d
SineWave [] sine = new SineWave[nb];//----------------------------------------------------- tableau d'oscillateurs
AudioOutput out;//------------------------------------------------------------------------- sortie audio g\u00e9n\u00e9rale

float [] freq = new float[nb];//----------------------------------------------------------- frequences pour chaque oscillateur
float vol [] = new float[nb];//------------------------------------------------------------ volume pour chaque oscillateur

public void setup()
{
  size(800, 400);
  smooth();

  controlP5 = new ControlP5(this);//--------------------------------------------------------- on cr\u00e9e une instance controP5
  minim = new Minim(this);//----------------------------------------------------------------- idem pour minim

  //----------------------------------------------------------------------------------------- on cr\u00e9e une sortie stereo, 
  //----------------------------------------------------------------------------------------- avec un buffer de 1024 (m\u00e9moire tampon)
  //----------------------------------------------------------------------------------------- a une fr\u00e9quence de 22000 Hz et 16 bits
  out = minim.getLineOut(Minim.STEREO, 1024, 22000, 16);

  for(int i=0; i<s.length; i++) {
    //----------------------------------------------------------------------------------------- on cr\u00e9e une onde sinusoidale \u00e0 440 hz (le LA du tel)
    sine[i] = new SineWave(440, 0.5f, out.sampleRate());
    //----------------------------------------------------------------------------------------- on cr\u00e9e un portamento est un glissement d'une note \u00e0 une autre
    sine[i].portamento(200);
    //----------------------------------------------------------------------------------------- on ajoute la forme d'onde \u00e0 la sortie
    out.addSignal(sine[i]);
    //----------------------------------------------------------------------------------------- mise en place des sliders2D
    String name = "sinusoide_"+(i+1);//-------------------------------------------------------- leur nom
    int h = width/(nb+5);//-------------------------------------------------------------------- leur taille
    int x = ((width/nb)*i) + h/2;//------------------------------------------------------------ leur position abscisse 
    int y = (height/16);//--------------------------------------------------------------------- leur position ordonn\u00e9e
    s[i] = controlP5.addSlider2D(name, x, y, h, h);//------------------------------------------ on cr\u00e9e autant de sliders qu'il y a d'oscillateurs
    s[i].setArrayValue(new float[] {//--------------------------------------------------------- pour initialiser la valeur du slider
      0, width/(nb+5)
    }
    );
    int c = color(0,0,0);
    s[i].setColorBackground(c);
    s[i].setColorValue(c);
    s[i].setColorLabel(c);
    //s[i].setLabelVisible(false);
  }
}

public void draw()
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
  //------------------------------------------------------------------------------------------ on r\u00e9\u00e9value les fr\u00e9quences et volumes des oscillateurs
  //------------------------------------------------------------------------------------------ \u00e0 partir des valeurs des sliders 2d
  for(int i=0; i<nb; i++) {
    freq[i] = map(s[i].arrayValue()[0], 0, width/(nb+5), 60, 1500);
    vol[i] = map(s[i].arrayValue()[1], 0, width/(nb+5), 0.5f, 0);
    sine[i].setFreq(freq[i]);
    sine[i].setAmp(vol[i]);
  }
}

public void stop()
{
  out.close();
  minim.stop();

  super.stop();
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "synthese" });
  }
}
