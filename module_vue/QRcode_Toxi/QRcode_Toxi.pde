/**
 * ZXingCamServer demo featuring:
 * <ul>
 * <li>wrapper for embedding Google ZXing QRcode/barcode decoder library</li>
 * <li>tracking of marker centroid in camera image</li>
 * <li>broadcasting marker URL and position to connected clients via TCP</li>
 * </ul>
 * <br/>
 * <a href="http://zxing.googlecode.com">ZXing v1.3</a> core binaries are bundled in the /code folder of the demo.
 *
 * Hold QR code in camera view to test recognition &amp; tracking <br/>
 * Press any key to toggle display mode between raw cam image and thresholded image<br/>
 * 
 * @author Karsten Schmidt <info at postspectacular dot com>
 * 
 * This demo is copyright 2008-2009 Karsten Schmidt.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import com.google.zxing.*;
import com.google.zxing.*;

import hypermedia.video.*;
import processing.net.*;

OpenCV opencv;
PImage buffer;

Server server;

boolean showConverted=false;

void setup() {
  size(640,480);
  textFont(createFont("ArialMT",12));
  opencv = new OpenCV(this);
  opencv.capture(width,height);
  //cam.settings();
  buffer=new PImage(width,height);
  buffer.format=ARGB;
  server = new Server(this, 10002);
}

void draw() {
  Client c = server.available();
  if (c != null) {
    String input = c.readString();
    println(input);
  }

  opencv.read();
  PImageMonochromeBitmapSource memImg=new PImageMonochromeBitmapSource(opencv.image());
  if (showConverted) {
    for(int i=0; i<opencv.image().height; i++) {
      memImg.estimateBlackPoint(BlackPointEstimationMethod.TWO_D_SAMPLING,0);
      BitArray row=memImg.getBlackRow(i,null,0,opencv.image().width);
      for(int x=0; x<opencv.image().width; x++) {
        if (row.get(x)) buffer.set(x,i,0xff000000);
        else buffer.set(x,i,0xffffffff);
      }
    }
    buffer.updatePixels();
    image(buffer,0,0);
  } 
  else {
    image(opencv.image(),0,0);
  }
  try {
    long now=System.nanoTime();
    com.google.zxing.Result result=new MultiFormatReader().decode(memImg);
    double fps=1000.0/((System.nanoTime()-now)*1e-6);
    println("avg: "+fps+" fps");
    ResultPoint[] points=result.getResultPoints();
    stroke(0,255,255);
    noFill();
    beginShape();
    float xc=0;
    float yc=0;
    for(int i=0; i<points.length; i++) {
      float x=points[i].getX();
      float y=points[i].getY();
      vertex(x,y);
      xc+=x;
      yc+=y;
    }
    endShape(CLOSE);
    xc*=0.25;
    yc*=0.25;
    fill(0);
    noStroke();
    rect(xc,yc-16,textWidth(result.getText())+8,16);
    fill(255);
    text(result.getText(),xc+4,yc-4);
    server.write(result.getText()+"$"+(int)xc+"$"+(int)yc);
  } 
  catch(Exception e) {
    // ignore if no QR code found
  }
}

void serverEvent(Server someServer, Client someClient) {
  println("We have a new client: " + someClient.ip());
}

void disconnectEvent(Client someClient) {
  println("client disconnected: "+ someClient.ip());
}

void keyPressed() {
  showConverted=!showConverted;
}

