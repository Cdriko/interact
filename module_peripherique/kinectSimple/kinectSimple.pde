
import shiffman.kinect.*;

PImage img;
PImage depth;

 void setup() {
  size(640,240);
  NativeKinect.init();
  img = createImage(640,480,RGB);
  depth = createImage(640,480,RGB);
}

 void draw() {
  NativeKinect.update();
  img.pixels = NativeKinect.getPixels();
  img.updatePixels();

  depth.pixels = NativeKinect.getDepthMap();
  depth.updatePixels();

  image(img,0,0,320,240);
  image(depth,320,0,320,240);
}
