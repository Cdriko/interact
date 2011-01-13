
//キャプチャを作成 !!!

import hypermedia.video.*;
import jp.nyatla.nyar4psg.*;
import processing.opengl.*;
import javax.media.opengl.*;

OpenCV opencv;
NyARBoard nya;
PFont font;

void setup() {
  size(320,240,OPENGL);
  colorMode(RGB, 100);
  font=createFont("FFScala", 32);

  opencv = new OpenCV(this);
  opencv.capture( width, height );
  //Left hand projection matrix
  nya=new NyARBoard(this,width,height,"camera_para.dat","patt.main",80);
  print(nya.VERSION);
  //Right hand projection matrix
  //nya=new NyARBoard(this,width,height,"camera_para.dat","patt.hiro",80,NyARBoard.CS_RIGHT);

  nya.gsThreshold=120;//画像２値化の閾値(0<n<255) default=110
  nya.cfThreshold=0.4;//変換行列計算を行うマーカ一致度(0.0<n<1.0) default=0.4
  //nya.lostDelay=10;//マーカ消失を無視する回数(0<n) default=10
}

void drawMarkerPos(int[][] points)// marquage des 4 angles du marqueur
{
  textFont(font,10.0);
  stroke(100,0,0);
  fill(100,0,0);
  for(int i=0;i<4;i++) {
    ellipse(nya.pos2d[i][0], nya.pos2d[i][1],5,5);
  }
  fill(0,0,0);
  for(int i=0;i<4;i++) {
    text("("+nya.pos2d[i][0]+","+nya.pos2d[i][1]+")",nya.pos2d[i][0],nya.pos2d[i][1]);
  }
}

String angle2text(float a)
{
  int i=(int)degrees(a);
  i=(i>0?i:i+360);
  return (i<100?"  ":i<10?" ":"")+Integer.toString(i);
}
String trans2text(float i)
{
  return (i<100?"  ":i<10?" ":"")+Integer.toString((int)i);
}

void draw() {
  background(255);
  opencv.read();
  hint(DISABLE_DEPTH_TEST);
  image( opencv.image(), 0, 0 );
  hint(ENABLE_DEPTH_TEST);

  if(nya.detect(opencv.image())) {
    hint(DISABLE_DEPTH_TEST);
    textFont(font,25.0);
    fill((int)((1.0-nya.confidence)*100),(int)(nya.confidence*100),0);
    text((int)(nya.confidence*100)+"%",width-60,height-20);
    pushMatrix();
    textFont(font,10.0);
    fill(0,100,0,80);
    translate((nya.pos2d[0][0]+nya.pos2d[1][0]+nya.pos2d[2][0]+nya.pos2d[3][0])/4+50,(nya.pos2d[0][1]+nya.pos2d[1][1]+nya.pos2d[2][1]+nya.pos2d[3][1])/4+50);
    text("TRANS "+trans2text(nya.trans.x)+","+trans2text(nya.trans.y)+","+trans2text(nya.trans.z),0,0);
    text("ANGLE "+angle2text(nya.angle.x)+","+angle2text(nya.angle.y)+","+angle2text(nya.angle.z),0,15);
    popMatrix();    
    drawMarkerPos(nya.pos2d);
    hint(ENABLE_DEPTH_TEST);

    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    nya.beginTransform(pgl);//マーカ座標系での描画を開始する。
    stroke(255,200,0);
    translate(0,0,20);
    box(40);
    nya.endTransform();
  }
}

