/**
 * Linear Averages
 * by Damien Di Fede.
 *  
 * This sketch demonstrates how to use the averaging abilities of the FFT.
 * 128 linearly spaced averages are requested and then those are drawn as rectangles.
 */
import nl.tudelft.ti1100a.audio.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
Minim minim;
AudioInput in;
FFT fft;

int i = 0;
int note = 0;
PImage canardimg;
PImage banzaiimg;
PImage bouteilleimg;
PImage coucouimg;
PImage nanaimg;
PImage sncfimg;
PImage sonnetteimg;
PImage laserimg;
PImage messageimg;
PImage humimg;
PImage uniteimg;
PImage bandeg;
PImage banded;

PFont font;
PFont fontsmall;
String joueur = "Joueur 1 commence ...";
String legend = "Dernier son utilisé";
String ajoute = "Ajoute un son ...";

MidiBus busA; //The first MidiBus

AudioSample canard;
AudioSample banzai;
AudioSample bouteille;
AudioSample coucou;
AudioSample nana;
AudioSample sncf;
AudioSample sonnette;
AudioSample laser;
AudioSample message;
AudioSample hum;
AudioSample unite;
//Variable Niveau
int niv =0;
//Variables Note 1
boolean canard0= false;
boolean banzai0=false;
boolean bouteille0=false;
boolean coucou0=false;
boolean nana0=false;
boolean sncf0=false;
boolean sonnette0=false;
boolean laser0=false;
boolean message0=false;
boolean hum0=false;
boolean unite0=false;
//Variables Note 2
boolean canard1= false;
boolean banzai1=false;
boolean bouteille1=false;
boolean coucou1=false;
boolean nana1=false;
boolean sncf1=false;
boolean sonnette1=false;
boolean laser1=false;
boolean message1=false;
boolean hum1=false;
boolean unite1=false;
//Variables Note 3
boolean canard2= false;
boolean banzai2=false;
boolean bouteille2=false;
boolean coucou2=false;
boolean nana2=false;
boolean sncf2=false;
boolean sonnette2=false;
boolean laser2=false;
boolean message2=false;
boolean hum2=false;
boolean unite2=false;
//Variables Note 4
boolean canard3= false;
boolean banzai3=false;
boolean bouteille3=false;
boolean coucou3=false;
boolean nana3=false;
boolean sncf3=false;
boolean sonnette3=false;
boolean laser3=false;
boolean message3=false;
boolean hum3=false;
boolean unite3=false;
//Variables Note 5
boolean canard4= false;
boolean banzai4=false;
boolean bouteille4=false;
boolean coucou4=false;
boolean nana4=false;
boolean sncf4=false;
boolean sonnette4=false;
boolean laser4=false;
boolean message4=false;
boolean hum4=false;
boolean unite4=false;
//Variables Note 6
boolean canard5= false;
boolean banzai5=false;
boolean bouteille5=false;
boolean coucou5=false;
boolean nana5=false;
boolean sncf5=false;
boolean sonnette5=false;
boolean laser5=false;
boolean message5=false;
boolean hum5=false;
boolean unite5=false;
//Variables Note 6
boolean canard6= false;
boolean banzai6=false;
boolean bouteille6=false;
boolean coucou6=false;
boolean nana6=false;
boolean sncf6=false;
boolean sonnette6=false;
boolean laser6=false;
boolean message6=false;
boolean hum6=false;
boolean unite6=false;




color bord0 = color(255);

import themidibus.*; //Import the library


void setup()
{
  size(1000, 800);
  minim = new Minim(this);
  smooth();
  // loop the file
  // create an FFT object that has a time-domain buffer the same size as jingle's sample buffer
  // and a sample rate that is the same as jingle's
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  in = minim.getLineIn(Minim.STEREO, 2048);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  // use 128 averages.
  // the maximum number of averages we could ask for is half the spectrum size. 
  fft.linAverages(64);
  frameRate(12);

  
  bandeg = loadImage("bande_gauche.jpg");
  banded = loadImage("bande_droite.jpg");
  canardimg = loadImage("canard.jpg");
  banzaiimg = loadImage("banzai.jpg");
  bouteilleimg = loadImage("bouteille.jpg");
  coucouimg = loadImage("coucou.jpg");
  nanaimg = loadImage("nana.jpg");
  sncfimg = loadImage("sncf.jpg");
  sonnetteimg = loadImage("sonnette.jpg");
  laserimg = loadImage("laser.jpg");
  messageimg = loadImage("message.jpg");
  humimg = loadImage("hum.jpg");
  uniteimg = loadImage("unite.jpg");


  font = loadFont("courier.vlw");
  fontsmall = loadFont("couriers.vlw");
  //SONS
  canard = minim.loadSample("canard.mp3", 2048);
  banzai=minim.loadSample("banzai.mp3", 2048);
  bouteille=minim.loadSample("bouteille.mp3", 2048);
  coucou=minim.loadSample("cuckoo.mp3", 2048);
  nana=minim.loadSample("nana.mp3", 2048);
  sncf=minim.loadSample("sncf.mp3", 2048);
  sonnette=minim.loadSample("sonnette.mp3", 2048);
  laser=minim.loadSample("laser.mp3", 2048);
  message=minim.loadSample("message.mp3", 2048);
  hum=minim.loadSample("huum.mp3", 2048);
  unite=minim.loadSample("unite.mp3", 2048);
  //MIDIBUS
  MidiBus.list(); //List all available Midi devices. This will show each device's index and name.

  //This is a different way of listing the available Midi devices. 
  println("Available MIDI Devices:"); 

  System.out.println("----------Input (from availableInputs())----------");
  String[] available_inputs = MidiBus.availableInputs(); //Returns an array of available input devices
  for(int i = 0;i < available_inputs.length;i++) System.out.println("["+i+"] \""+available_inputs[i]+"\"");

  System.out.println("----------Output (from availableOutputs())----------");
  String[] available_outputs = MidiBus.availableOutputs(); //Returns an array of available output devices
  for(int i = 0;i < available_outputs.length;i++) System.out.println("["+i+"] \""+available_outputs[i]+"\"");

  System.out.println("----------Unavailable (from unavailableDevices())----------");
  String[] unavailable = MidiBus.unavailableDevices(); //Returns an array of unavailable devices
  for(int i = 0;i < unavailable.length;i++) System.out.println("["+i+"] \""+unavailable[i]+"\"");

  busA = new MidiBus(this, 0, 2, "busA"); //Create a first new MidiBus attached to the IncommingA Midi input device and the OutgoingA Midi output device. We will name it busA.


  busA.addOutput("OutgoingC"); //Add a new output device to busA called OutgoingC

}

void draw()
{
    background(255);
  image(bandeg, 0, 100 , 180, 700);
  image(banded, 820, 100 , 180, 700);


  // SPECTRE SONORE
  stroke(0);
  fill(255);
  rectMode(CORNERS);
  // perform a forward FFT on the samples in jingle's mix buffer
  // note that if jingle were a MONO file, this would be the same as using jingle.left or jingle.right
  fft.forward(in.mix);
  int w = int(fft.specSize()/64);
  for(int i = 0; i < fft.avgSize(); i++)
  {
    // draw a rectangle for each average, multiply the value by 5 so we can see it better
    rect(i*w, 100, i*w + w, 100 - fft.getAvg(i)*5);
  }
  rectMode(CORNER);


  //TEXTE DE FEEDBACK
  fill(0);
  textFont(font,30);
  text(joueur,250,170);
  textFont(font,20);
  text(legend,300,700);
  textFont(fontsmall,35);
  text(ajoute,250,200);

  //RESTART
  println(mouseX+" "+mouseY);
  fill(255, 49, 0);
  triangle(498,711,591,742,498,771);
  fill(255);
  textFont(fontsmall, 25);
  text("Rejouer",500,750);
  if(mouseX<600 && mouseX>500 && mouseY<750 && mouseY>725) {
    cursor(HAND);
  }
  else {
    cursor(ARROW);
  }
  if(mouseX<600 && mouseX>500 && mouseY<750 && mouseY>725 && mousePressed) {
    niv =0;
    note =0;
    bord0 = color(255);
    i = 0;
    //Variables Note 1
    canard0= false;
    banzai0=false;
    bouteille0=false;
    coucou0=false;
    nana0=false;
    sncf0=false;
    sonnette0=false;
    laser0=false;
    message0=false;
    hum0=false;
    unite0=false;
    //Variables Note 2
    canard1= false;
    banzai1=false;
    bouteille1=false;
    coucou1=false;
    nana1=false;
    sncf1=false;
    sonnette1=false;
    laser1=false;
    message1=false;
    hum1=false;
    unite1=false;
    //Variables Note 3
    canard2= false;
    banzai2=false;
    bouteille2=false;
    coucou2=false;
    nana2=false;
    sncf2=false;
    sonnette2=false;
    laser2=false;
    message2=false;
    hum2=false;
    unite2=false;
    //Variables Note 4
    canard3= false;
    banzai3=false;
    bouteille3=false;
    coucou3=false;
    nana3=false;
    sncf3=false;
    sonnette3=false;
    laser3=false;
    message3=false;
    hum3=false;
    unite3=false;
    //Variables Note 5
    canard4= false;
    banzai4=false;
    bouteille4=false;
    coucou4=false;
    nana4=false;
    sncf4=false;
    sonnette4=false;
    laser4=false;
    message4=false;
    hum4=false;
    unite4=false;
    //Variables Note 6
    canard5= false;
    banzai5=false;
    bouteille5=false;
    coucou5=false;
    nana5=false;
    sncf5=false;
    sonnette5=false;
    laser5=false;
    message5=false;
    hum5=false;
    unite5=false;
    //Variables Note 6
    canard6= false;
    banzai6=false;
    bouteille6=false;
    coucou6=false;
    nana6=false;
    sncf6=false;
    sonnette6=false;
    laser6=false;
    message6=false;
    hum6=false;
    unite6=false;

    joueur = "Joueur 1 commence ...";
    ajoute = "Ajoute un son ...";
    noStroke();
    fill(255);
    rect(250, 240, 400, 400);
  }
  println(note);
  println(niv);
  //PREMIERE NOTE

  if(canard0==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite0==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }


  if(canard1==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite1==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }

  if(canard2==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite2==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }

  if(canard3==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite3==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }

  if(canard4==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite4==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }

  if(canard5==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite5==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }
  
    if(canard6==true) {
    fill(bord0);
    rect(662,162,45,45);
    image(canardimg, 250, 240, 400, 400);
  }

  if(banzai6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(banzaiimg, 250, 240, 400, 400);
  }

  if(bouteille6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(bouteilleimg, 250, 240, 400, 400);
  }

  if(coucou6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(coucouimg, 250, 240, 400, 400);
  }

  if(nana6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(nanaimg, 250, 240, 400, 400);
  }

  if(sncf6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sncfimg, 250, 240, 400, 400);
  }

  if(sonnette6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(sonnetteimg, 250, 240, 400, 400);
  }

  if(laser6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(laserimg, 250, 240, 400, 400);
  }

  if(message6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(messageimg, 250, 240, 400, 400);
  }

  if(hum6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(humimg, 250, 240, 400, 400);
  }

  if(unite6==true) {
    fill(bord0);
    rect(662,162,45,45);
    fill(255);
    image(uniteimg, 250, 240, 400, 400);
  }
  //----------------------------------------
}


// APPUI SUR NOTES
//----------------------------------------//----------------------------------------//----------------------------------------//----------------------------------------//----------------------------------------
void noteOn(int channel, int pitch, int velocity, String bus_name) {
  //NOTE 0
  println(pitch);
  if(note==0) {

    if (pitch == 36) { 
      canard.trigger();
      canard0= true;
      note++;
      pitch = 0;
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 43) { 
      nana.trigger();
      nana0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 48) { 
      laser.trigger();
      laser0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 50) { 
      message.trigger();
      message0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 52) { 
      hum.trigger();
      hum0=true;
      note++;
      pitch = 0;
    }

    if (pitch == 53) { 
      unite.trigger();
      unite0=true;
      note++;
      pitch = 0;
    }
  }
  if(note==1 && niv==0) {
    ajoute = "Joue les sons";
    joueur = "Joueur 2 à toi ...";
    if (pitch == 36 ) {
      if(canard0==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(canard0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 38 ) {
      if(banzai0==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(banzai0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 40) { 
      if(bouteille0==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(bouteille0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 41 ) { 
      if(coucou0==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(coucou0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 43 ) { 
      if(nana0==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(nana0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 45 ) { 
      if(sncf0==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(sncf0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 47) { 
      if(sonnette0==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(sonnette0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 48) { 
      if(laser0==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(laser0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 50) { 
      if(message0==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(message0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 52) { 
      if(hum0==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(hum0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 53 ) { 
      if(unite0==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =1;
        pitch=0;
      }
      if(unite0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }
  }

  if(note == 1 && niv == 1) {

    ajoute = "Ajoute un son";
    if (pitch == 36) { 
      canard.trigger();
      canard1= true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 43) { 
      nana.trigger();
      nana1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 48) { 
      laser.trigger();
      laser1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 50) { 
      message.trigger();
      message1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 52) { 
      hum.trigger();
      hum1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 53) { 
      unite.trigger();
      unite1=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
  }
  if(note == 2 && niv == 1) {
    ajoute = "Joue les sons";
    if (pitch == 36 ) {
      if(canard0==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(canard0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 38 ) {
      if(banzai0==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(banzai0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 40) { 
      if(bouteille0==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(bouteille0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 41 ) { 
      if(coucou0==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(coucou0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 43 ) { 
      if(nana0==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(nana0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 45 ) { 
      if(sncf0==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(sncf0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 47) { 
      if(sonnette0==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(sonnette0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 48) { 
      if(laser0==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(laser0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 50) { 
      if(message0==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(message0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 52) { 
      if(hum0==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(hum0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 53 ) { 
      if(unite0==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =2;
        pitch=0;
      }
      if(unite0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }
  }



  if(note == 2 && niv == 2) {
    if (pitch == 36 ) {
      if(canard1==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(canard1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 38 ) {
      if(banzai1==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(banzai1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 40) { 
      if(bouteille1==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(bouteille1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 41 ) { 
      if(coucou1==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(coucou1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 43 ) { 
      if(nana1==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(nana1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 45 ) { 
      if(sncf1==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(sncf1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 47) { 
      if(sonnette1==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(sonnette1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 48) { 
      if(laser1==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(laser1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 50) { 
      if(message1==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(message1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 52) { 
      if(hum1==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(hum1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }

    if (pitch == 53 ) { 
      if(unite1==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =3;
        pitch=0;
      }
      if(unite1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
        ajoute = " ";
      }
    }
  }


  if(note == 2 && niv == 3) {
    ajoute = "Ajoute un son";
    if (pitch == 36) { 
      canard.trigger();
      canard2= true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 43) { 
      nana.trigger();
      nana2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 48) { 
      laser.trigger();
      laser2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 50) { 
      message.trigger();
      message2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 52) { 
      hum.trigger();
      hum2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 53) { 
      unite.trigger();
      unite2=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }
  }
  if(note == 3 && niv == 3) {
    ajoute = "Joue les sons";
    if (pitch == 36 ) {
      if(canard0==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(canard0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai0==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(banzai0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille0==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(bouteille0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou0==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(coucou0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana0==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(nana0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf0==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(sncf0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette0==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(sonnette0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser0==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(laser0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message0==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(message0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum0==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(hum0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite0==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =4;
        pitch=0;
      }
      if(unite0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note == 3 && niv == 4) {
    if (pitch == 36 ) {
      if(canard1==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(canard1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai1==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(banzai1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille1==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(bouteille1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou1==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(coucou1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana1==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(nana1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf1==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(sncf1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette1==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(sonnette1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser1==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(laser1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message1==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(message1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum1==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =5;
        pitch=0;
      }
      if(hum1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==3 && niv==5) {
    if (pitch == 36 ) {
      if(canard2==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(canard2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai2==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(banzai2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille2==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(bouteille2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou2==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(coucou2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana2==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(nana2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf2==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(sncf2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette2==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(sonnette2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser2==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(laser2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message2==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(message2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum2==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(hum2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53) { 
      if(unite2==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =6;
        pitch=0;
      }
      if(unite2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }

  if(note==3 && niv==6) {
    ajoute = "Ajoute un son";
    if (pitch == 36) { 
      canard.trigger();
      canard3= true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 43) { 
      nana.trigger();
      nana3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 48) { 
      laser.trigger();
      laser3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 50) { 
      message.trigger();
      message3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 52) { 
      hum.trigger();
      hum3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 53) { 
      unite.trigger();
      unite3=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
  }

  if(note==4 && niv==6) {
    ajoute = "Joue les sons";
    if (pitch == 36 ) {
      if(canard0==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(canard0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai0==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(banzai0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille0==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(bouteille0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou0==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(coucou0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana0==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(nana0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf0==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(sncf0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette0==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(sonnette0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser0==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(laser0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message0==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(message0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum0==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(hum0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite0==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =7;
        pitch=0;
      }
      if(unite0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==4 && niv==7) {
    if (pitch == 36 ) {
      if(canard1==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(canard1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai1==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(banzai1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille1==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(bouteille1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou1==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(coucou1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana1==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(nana1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf1==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(sncf1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette1==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(sonnette1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser1==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(laser1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message1==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(message1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum1==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(hum1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite1==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =8;
        pitch=0;
      }
      if(unite1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }

  if(note==4 && niv==8) {
    if (pitch == 36 ) {
      if(canard2==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(canard2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai2==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(banzai2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille2==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(bouteille2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou2==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(coucou2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana2==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(nana2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf2==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(sncf2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette2==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(sonnette2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser2==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(laser2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message2==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(message2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum2==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(hum2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
    if (pitch == 53 ) { 
      if(unite2==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =9;
        pitch=0;
      }
      if(unite2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==4 && niv==9) {
    if (pitch == 36 ) {
      if(canard3==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(canard3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai3==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(banzai3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille3==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(bouteille3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou3==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(coucou3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana3==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(nana3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf3==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(sncf3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette3==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(sonnette3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser3==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(laser3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message3==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(message3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum3==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(hum3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite3==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =10;
        pitch=0;
      }
      if(unite3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==4 && niv==10) {
    ajoute = "Ajoute un son";
    if (pitch == 36) { 
      canard.trigger();
      canard4= true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 43) { 
      nana.trigger();
      nana4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 48) { 
      laser.trigger();
      laser4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 50) { 
      message.trigger();
      message4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 52) { 
      hum.trigger();
      hum4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }

    if (pitch == 53) { 
      unite.trigger();
      unite4=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 2 à toi ...";
    }
  }
  if(note==5 && niv==10) {
    ajoute = "Joue les sons";
    if (pitch == 36 ) {
      if(canard0==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(canard0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai0==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(banzai0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille0==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(bouteille0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou0==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(coucou0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana0==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(nana0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf0==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(sncf0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette0==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(sonnette0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser0==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(laser0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message0==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(message0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum0==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(hum0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite0==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =11;
        pitch=0;
      }
      if(unite0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==5 && niv==11) {
    if (pitch == 36 ) {
      if(canard1==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(canard1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai1==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(banzai1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille1==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(bouteille1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou1==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(coucou1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana1==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(nana1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf1==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(sncf1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette1==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(sonnette1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser1==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(laser1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message1==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(message1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum1==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(hum1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite1==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =12;
        pitch=0;
      }
      if(unite1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==5 && niv==12) {
    if (pitch == 36 ) {
      if(canard2==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(canard2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai2==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(banzai2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille2==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(bouteille2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou2==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(coucou2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana2==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(nana2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf2==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(sncf2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette2==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(sonnette2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser2==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(laser2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message2==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(message2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum2==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(hum2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
    if (pitch == 53 ) { 
      if(unite2==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =13;
        pitch=0;
      }
      if(unite2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==5 && niv==13) {
    if (pitch == 36 ) {
      if(canard3==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(canard3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai3==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(banzai3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille3==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(bouteille3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou3==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(coucou3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana3==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(nana3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf3==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(sncf3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette3==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(sonnette3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser3==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(laser3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message3==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(message3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum3==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(hum3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite3==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =14;
        pitch=0;
      }
      if(unite3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==5 && niv==14) {
    if (pitch == 36 ) {
      if(canard4==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(canard4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai4==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(banzai4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille4==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(bouteille4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou4==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(coucou4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana4==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(nana4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf4==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(sncf4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette4==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(sonnette4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser4==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(laser4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message4==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(message4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum4==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(hum4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite4==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =15;
        pitch=0;
      }
      if(unite4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==5 && niv==15) {
    ajoute = "Ajoute un son";
    if (pitch == 36) { 
      canard.trigger();
      canard5= true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 43) { 
      nana.trigger();
      nana5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 48) { 
      laser.trigger();
      laser5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 50) { 
      message.trigger();
      message5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 52) { 
      hum.trigger();
      hum5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 53) { 
      unite.trigger();
      unite5=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
  }
  if(note==6 && niv==15) {
    ajoute = "Joue les sons";
    if (pitch == 36 ) {
      if(canard0==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(canard0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai0==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(banzai0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille0==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(bouteille0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou0==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(coucou0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana0==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(nana0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf0==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(sncf0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette0==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(sonnette0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser0==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(laser0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message0==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(message0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum0==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(hum0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite0==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =16;
        pitch=0;
      }
      if(unite0==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==6 && niv==16) {
    if (pitch == 36 ) {
      if(canard1==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(canard1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai1==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(banzai1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille1==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(bouteille1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou1==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(coucou1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana1==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(nana1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf1==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(sncf1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette1==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(sonnette1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser1==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(laser1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message1==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(message1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum1==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(hum1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite1==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =17;
        pitch=0;
      }
      if(unite1==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==6 && niv==17) {
    if (pitch == 36 ) {
      if(canard2==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(canard2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai2==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(banzai2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille2==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(bouteille2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou2==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(coucou2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana2==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(nana2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf2==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(sncf2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette2==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(sonnette2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser2==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(laser2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message2==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(message2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum2==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(hum2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53) { 
      if(unite2==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =18;
        pitch=0;
      }
      if(unite2==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==6 && niv==18) {
    if (pitch == 36 ) {
      if(canard3==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(canard3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai3==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(banzai3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille3==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(bouteille3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou3==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(coucou3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana3==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(nana3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf3==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(sncf3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette3==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(sonnette3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser3==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(laser3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message3==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(message3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum3==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(hum3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite3==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =19;
        pitch=0;
      }
      if(unite3==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==6 && niv==19) {
    if (pitch == 36 ) {
      if(canard4==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(canard4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai4==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(banzai4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille4==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(bouteille4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou4==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(coucou4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana4==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(nana4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf4==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(sncf4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette4==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(sonnette4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser4==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(laser4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message4==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(message4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum4==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(hum4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite4==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =20;
        pitch=0;
      }
      if(unite4==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==6 && niv==20) {
    if (pitch == 36 ) {
      if(canard5==true) { 
        canard.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(canard5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 38 ) {
      if(banzai5==true) { 
        banzai.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(banzai5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 40) { 
      if(bouteille5==true) { 
        bouteille.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(bouteille5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 41 ) { 
      if(coucou5==true) { 
        coucou.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(coucou5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 43 ) { 
      if(nana5==true) { 
        nana.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(nana5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 45 ) { 
      if(sncf5==true) { 
        sncf.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(sncf5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 47) { 
      if(sonnette5==true) { 
        sonnette.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(sonnette5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 48) { 
      if(laser5==true) { 
        laser.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(laser5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 50) { 
      if(message5==true) { 
        message.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(message5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 52) { 
      if(hum5==true) { 
        hum.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(hum5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }

    if (pitch == 53 ) { 
      if(unite5==true) { 
        unite.trigger();
        bord0 = color(14, 172, 0);
        niv =21;
        pitch=0;
      }
      if(unite5==false) {
        bord0=color(254, 0, 0);
        joueur = "Game Over";
      }
    }
  }
  if(note==6 && niv==21) {
    ajoute = "Ajoute un son";
    if (pitch == 36) { 
      canard.trigger();
      canard6= true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
    if (pitch == 38) { 
      banzai.trigger();
      banzai6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 40) { 
      bouteille.trigger();
      bouteille6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 41) { 
      coucou.trigger();
      coucou6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 43) { 
      nana.trigger();
      nana6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 45) { 
      sncf.trigger();
      sncf6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 47) { 
      sonnette.trigger();
      sonnette6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 48) { 
      laser.trigger();
      laser6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 50) { 
      message.trigger();
      message6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 52) { 
      hum.trigger();
      hum6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }

    if (pitch == 53) { 
      unite.trigger();
      unite6=true;
      note++;
      pitch = 0;
      bord0 = color(255);
      joueur = "Joueur 1 à toi ...";
    }
  }
  if(note==7) {
    joueur = "Partie terminée ! Bien joué !";
    ajoute = "Ecoutez votre production ...";
    delay(3000);
    if(nana0==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard0==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai0==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille0==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou0==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf0==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette0==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser0==true) {
      laser.trigger();
      delay(2000);
    }
    if(message0==true) {
      message.trigger();
      delay(2000);
    }
    if(hum0==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite0==true) {
      unite.trigger();
      delay(2000);
    }
    if(nana0==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard1==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai1==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille1==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou1==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf1==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette1==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser1==true) {
      laser.trigger();
      delay(2000);
    }
    if(message1==true) {
      message.trigger();
      delay(2000);
    }
    if(hum1==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite1==true) {
      unite.trigger();
      delay(2000);
    }
    
        if(nana2==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard2==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai2==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille2==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou2==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf2==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette2==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser2==true) {
      laser.trigger();
      delay(2000);
    }
    if(message2==true) {
      message.trigger();
      delay(2000);
    }
    if(hum2==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite2==true) {
      unite.trigger();
      delay(2000);
    }
        if(nana3==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard3==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai3==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille3==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou3==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf3==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette3==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser3==true) {
      laser.trigger();
      delay(2000);
    }
    if(message3==true) {
      message.trigger();
      delay(2000);
    }
    if(hum3==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite3==true) {
      unite.trigger();
      delay(2000);
    }
        if(nana4==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard4==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai4==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille4==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou4==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf4==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette4==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser4==true) {
      laser.trigger();
      delay(2000);
    }
    if(message4==true) {
      message.trigger();
      delay(2000);
    }
    if(hum4==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite4==true) {
      unite.trigger();
      delay(2000);
    }
        if(nana5==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard5==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai5==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille5==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou5==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf5==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette5==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser5==true) {
      laser.trigger();
      delay(2000);
    }
    if(message5==true) {
      message.trigger();
      delay(2000);
    }
    if(hum5==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite5==true) {
      unite.trigger();
      delay(2000);
    }
        if(nana6==true) {
      nana.trigger();
      delay(2000);
    }
    if(canard6==true) {
      canard.trigger();
      delay(2000);
    }
    if(banzai6==true) {
      banzai.trigger();
      delay(2000);
    }
    if(bouteille6==true) {
      bouteille.trigger();
      delay(2000);
    }
    if(coucou6==true) {
      coucou.trigger();
      delay(2000);
    }
    if(sncf6==true) {
      sncf.trigger();
      delay(2000);
    }
    if(sonnette6==true) {
      sonnette.trigger();
      delay(2000);
    }
    if(laser6==true) {
      laser.trigger();
      delay(2000);
    }
    if(message6==true) {
      message.trigger();
      delay(2000);
    }
    if(hum6==true) {
      hum.trigger();
      delay(2000);
    }
    if(unite6==true) {
      unite.trigger();
      delay(2000);
    }
  }
  
}
void stop() 
{
  // always close Minim audio classes when you finish with them
  in.close();
  minim.stop();

  super.stop();
}

