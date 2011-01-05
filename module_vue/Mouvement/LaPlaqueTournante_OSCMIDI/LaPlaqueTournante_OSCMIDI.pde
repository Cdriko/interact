import JMyron.*;
import promidi.*;
import oscP5.*;
import netP5.*;
//--------------------------
MidiOut midiOut;
MidiIO midiIO;
OscP5 oscP5;
NetAddress myRemoteLocation;
JMyron m;
//--------------------------
PImage livecam;
int tolerance=200;
int numPixels;
int[]live;
int w,v;
//---------------------------
int numFlaps=8;
Flaps [] flap = new Flaps[numFlaps];
int[] flapsOn=new int[numFlaps];
int[] x;
int[] y;
int[] l={
  10,10,10,10,10,10,10,10};
int[] h={
  80,80,80,80,80,80,80,80};
int[] num={
  60,61,62,63,64,65,66,67};
int[] oscVal ={
  1,0,0,1,1,1,1,0};
int c=255;

void setup() {
  smooth();
  w=320;
  v=240;
  size(320, 240);

  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);

  midiIO = MidiIO.getInstance(this);
  midiOut = midiIO.getMidiOut(0,0);
  //midiIO.printDevices();
  //println("<<<<<<<<<< Ports Midi >>>>>>>>>>");

  m = new JMyron();
  m.start(width,height);
  m.adaptivity(10);
  m.findGlobs(0);
  m.minDensity(7);

  numPixels = width * height;
  livecam = new PImage(w,v);
  int az=width/8;
  int dost=10;
  int[]x={
    dost,az+dost,az*2+dost,az*3+dost+5,az*4+dost+10,az*5+dost+10,az*6+dost+15,az*7+dost+15
  };
  int[]y={
    30,30,30,30,30,30,30,30
  };
  for(int i=0;i<numFlaps;i++){
    flap[i]= new Flaps(x[i],y[i],l[i],h[i],c,num[i],oscVal[i]);

  }

}

void draw() {
  background(125);
  image(livecam,0,0,320,240);
  m.update();
  int[] live= m.cameraImage();
  int[] img = m.differenceImage(); 
  livecam.loadPixels(); 

  for(int j=0;j<numFlaps;j++){
    flap[j].display();
    flapsOn[j]=0;
  }

  for (int i = 0; i < numPixels; i++) { 
    color currColor = img[i];
    livecam.pixels[i]=live[i];
    int currR = (currColor >> 16) & 0xFF; 
    int currG = (currColor >> 8) & 0xFF;
    int currB = currColor & 0xFF;

    if(currR + currG + currB>tolerance){
      int px=i%width;
      int py=int(i/width)+1;

      for(int j=0;j<numFlaps;j++){
        if (flapsOn[j]==0){
          if(flap[j].overFlap(px,py)){
            flap[j].action();
            flapsOn[j]=1;
            break;
          }
        }
      }
    }
  }
  livecam.updatePixels();
}





