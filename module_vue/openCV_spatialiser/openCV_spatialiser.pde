/**
 *
 *by Cedric Doutriaux . 
 analyse de mouvement pour une exploitation spatiale
 */


PFont fontA;





void setup() {
  size(320, 320); 
  fontA = loadFont("CourierNew36.vlw");
  textFont(fontA, 12);  
  fill(120, 122, 123);
  text("initialisation...", 10, 255);
  init_motion();
}

void draw() {
  background(0);
  MotionDetect();
}





















