import processing.serial.*;

String portstr = "/dev/tty.usbserial-A3000Xv0";
String urlstr = "http://todbot.com/tst/color.txt";
int refreshTime = 10 * 1000;  // every 60 seconds;
int lastTime;

Serial port;
color c;

PFont font;

void setup() {
  size(500,500);
  frameRate(1);

  font = loadFont("Futura-MediumItalic-48.vlw"); 
  fill(153);
  textFont(font, 48); 
  text(urlstr, 10, height/2); 

  port = new Serial(this, portstr, 9600);

  lastTime = 0;
  getWebColor();
} 

void draw() {
  background( c );

  int n = (int)((refreshTime-(millis()-lastTime))/1000)+1;
  println("countdown to color: "+ n);
  text( n, 10, 50);

  if( millis() - lastTime >= refreshTime ) {
    getWebColor();
    lastTime = millis();
  }
}

void getWebColor() {
  try {
    URL url = new URL(urlstr);
    URLConnection conn = url.openConnection();
    conn.connect();

    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String inputLine;
    while ((inputLine = in.readLine()) != null) {
      System.out.println("   content: "+inputLine);
      if( inputLine.startsWith("#")) {
        int ic = Integer.decode(inputLine).intValue();
        c = color((ic>>16)&0xff,(ic>>8)&0xff,(ic>>0)&0xff); 
        String cs = Integer.toHexString(ic);
        if(cs.length() == 1) cs = "00000"+cs;  // fix broken toHexString() behavior
        if(cs.length() == 2) cs = "0000"+cs;
        if(cs.length() == 3) cs = "000"+cs; 
        if(cs.length() == 4) cs = "00"+cs;
        if(cs.length() == 5) cs = "0"+cs; 
        println("parsed color #"+cs);
        port.write("#"+cs);
        return;
      }
    }
  }  
  catch (Exception ex) {
    ex.printStackTrace();
    System.out.println("ERROR: "+ex.getMessage());
  }

}
