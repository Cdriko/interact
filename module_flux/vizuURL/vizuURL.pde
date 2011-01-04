// URL grab
// Daniel Shiffman <http://www.shiffman.net>

// Visualize source code of URL as grayscale color

String urlSource;  // A String to hold the information from a URL
int count = 0;     // Current character from URL
int x = 0;         // Current x location

PFont f;           // Variable to hold onto a font

void setup() {
  size(200,200);
  String[] data = loadStrings("http://www.yahoo.com");  // load URL as an array of Strings
  urlSource = join(data," ");                           // join array together as one long String
  f = loadFont("GillSans-12.vlw");                      // load Font
  frameRate(30);
}

void  draw() {
  
  // Grab one character from html source
  char c = urlSource.charAt(count);
  count = (count + 1) % urlSource.length();
  
  // display a rectangle with color according to ASCII value of character
  fill(c,126);
  noStroke();
  rect(x,0,10,height);
  x = (x + 10) % width;
  
  // Display character
  textFont(f);
  fill(255);
  text(c,x,height/2);
}
