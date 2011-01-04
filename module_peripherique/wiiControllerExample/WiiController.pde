class WiiController {

  OscP5 oscP5;  
  boolean buttonA, buttonB, buttonUp, buttonDown, buttonLeft, buttonRight;
  boolean buttonOne, buttonTwo, buttonMinus, buttonPlus, buttonHome;
  boolean isConnected;
  float roll;
  float pitch;
  Acceleration acc;
  float x,y;
  float b,n;
  float batterylevel;
  boolean DEBUG = false;
  
  WiiController() {
    oscP5 = new OscP5(this,5600);
    oscP5.plug(this,"connected","/wii/connected");// i
    oscP5.plug(this,"mousemode","/wii/mousemode");// i
    oscP5.plug(this,"buttonA","/wii/button/a");// i
    oscP5.plug(this,"buttonB","/wii/button/b");// i
    oscP5.plug(this,"buttonUp","/wii/button/up");// i
    oscP5.plug(this,"buttonDown","/wii/button/down");// i
    oscP5.plug(this,"buttonLeft","/wii/button/left");// i
    oscP5.plug(this,"buttonRight","/wii/button/right");// i
    oscP5.plug(this,"buttonMinus","/wii/button/minus");// i
    oscP5.plug(this,"buttonPlus","/wii/button/plus");// i
    oscP5.plug(this,"buttonHome","/wii/button/home");// i
    oscP5.plug(this,"buttonOne","/wii/button/one");// i
    oscP5.plug(this,"buttonTwo","/wii/button/two");// i
    oscP5.plug(this,"acceleration","/wii/acc");
    oscP5.plug(this,"orientation","/wii/orientation");
    oscP5.plug(this,"point","/wii/point");
    oscP5.plug(this,"irpoint","/wii/irpoint");
    oscP5.plug(this,"batterylevel","/wii/batterylevel");
    acc = new Acceleration();
  }
  
  
  void connected(int theValue) {
    isConnected = (theValue==0) ? false:true;
  }

  void mousemode(int theMode) {
  }

  void acceleration(float theX, float theY, float theZ) {
    acc.x = theX;
    acc.y = theY;
    acc.z = theZ;
    if(DEBUG) {
      println("acceleration  x:"+acc.x+" y:"+acc.y+"  z:"+acc.z);
    }
  }

  void orientation(float theRoll, float thePitch) {
    roll += (theRoll - roll)*0.04;
    pitch += (thePitch - pitch)*0.04;
    if(DEBUG) {
      println("orientation roll:"+roll+"   pitch:"+pitch);
    }
  }
  
  void point(float theX, float theY) {
    x += (theX -x)*0.04;
    y += (theY -y)*0.04;
  }

  void irpoint(float theX, float theY) {

  }

  void buttonA(int theValue) {
    buttonA = (theValue==1) ? true:false;
  }

  void buttonB(int theValue) {
    buttonB = (theValue==1) ? true:false;
  }

  void buttonOne(int theValue) {
    buttonOne = (theValue==1) ? true:false;
  }

  void buttonTwo(int theValue) {
    buttonTwo = (theValue==1) ? true:false;
  }

  void buttonMinus(int theValue) {
    buttonMinus = (theValue==1) ? true:
    false;
  }

  void buttonPlus(int theValue) {
    buttonPlus = (theValue==1) ? true:false;
  }

  void buttonUp(int theValue) {
    buttonUp = (theValue==1)  ? true:false;
  }

  void buttonDown(int theValue) {
    buttonDown = (theValue==1) ? true:false;
  }

  void buttonHome(int theValue) {
    buttonHome = (theValue==1) ? true:false;
  }
  
  void batterylevel(float theValue) {
    println("BatteryLevel: "+theValue);
    batterylevel = theValue;
  }

  class Acceleration {
    float x,y,z;
  }
}
