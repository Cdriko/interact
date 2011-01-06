/**	NyARToolkit for proce55ing/0.3.0
	(c)2008-2010 nyatla
	airmail(at)ebony.plala.or.jp

  example modified to demonstrate NyARMultiBoard + NyARMultiBoardMarker by
  Charl P. Botha <http://cpbotha.net/>
*/
 
import codeanticode.gsvideo.*;
import jp.nyatla.nyar4psg.*;
import processing.opengl.*;
import javax.media.opengl.*;

GSCapture cam;
NyARMultiBoard nya;
PFont font;

void setup() {
  size(640,480,OPENGL);
  colorMode(RGB, 100);
  font=createFont("FFScala", 32);
  // I'm using the GSVideo capture stack
  cam=new GSCapture(this,width,height);
  // array of pattern file names, these have to be in NyARMultiTest/data
  String[] patts = {"patt.hiro", "patt.kanji"};
  // array of corresponding widths in mm
  double[] widths = {80,80};
  // initialise the NyARMultiBoard
  nya=new NyARMultiBoard(this,width,height,"camera_para.dat",patts,widths);
  print(nya.VERSION);

  nya.gsThreshold=120;//(0<n<255) default=110
  nya.cfThreshold=0.4;//(0.0<n<1.0) default=0.4

}

void drawMarkerPos(int[][] pos2d)
{
  textFont(font,10.0);
  stroke(100,0,0);
  fill(100,0,0);
  
  // draw ellipses at outside corners of marker
  for(int i=0;i<4;i++){
    ellipse(pos2d[i][0], pos2d[i][1],5,5);
  }
  
  fill(0,0,0);
  for(int i=0;i<4;i++){
    text("("+pos2d[i][0]+","+pos2d[i][1]+")",pos2d[i][0],pos2d[i][1]);
  }
}

void draw() {
  if (cam.available() !=true) {
    return;
  }

  background(255);
  cam.read();
  //背景を描画
  hint(DISABLE_DEPTH_TEST);
  image(cam,0,0);
  hint(ENABLE_DEPTH_TEST);

  //マーカの検出。マーカが発見されるとdetectはTRUEを返す。
  if (nya.detect(cam))
  {
    hint(DISABLE_DEPTH_TEST);
    for (int i=0; i < nya.markers.length; i++)
    {
      if (nya.markers[i].detected)
      {
        drawMarkerPos(nya.markers[i].pos2d);
      }
    }
    
    hint(ENABLE_DEPTH_TEST);

    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
    for (int i=0; i < nya.markers.length; i++)
    {
      if (nya.markers[i].detected)
      {
       nya.markers[i].beginTransform(pgl);

       translate(0,0,20);

       // if it's the hiro marker, draw a cube
       if (i == 0)
       {
       stroke(255,200,0);
       box(40);
       }
       // else draw a sphere
       else
       {
       stroke(0,200,255);
       sphere(25);
       }
       nya.markers[i].endTransform();
       
      }
    }
    
    
  }
  
  
  
  

}

