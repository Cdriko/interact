import org.openkinect.*;
import org.openkinect.processing.*;

Kinect kinect;
boolean depth = true;
boolean rgb = false;

void setup() {
  size(1280,520);
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(depth);
  kinect.enableRGB(rgb);
}

void draw() {
  background(0);
  image(kinect.getRGBImage(),0,0);
  image(kinect.getDepthImage(),640,0);
  fill(255);
  text("RGB FPS: " + kinect.getRGBFPS(),10,495);
  text("DEPTH FPS: " + kinect.getDepthFPS(),640,495);
  text("Press 'd' to enable/disable depth    Press 'r' to enable/disable rgb image    Framerate: " + frameRate,10,515);
}

void keyPressed() {
  if (key == 'd') {
    depth = !depth;
    kinect.enableDepth(depth);
  } 
  else if (key == 'r') {
    rgb = !rgb;
    kinect.enableRGB(rgb);
  }
}

void stop() {
  kinect.quit();
  super.stop();
}


