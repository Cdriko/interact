class Flaps{
  int x,y,l,h,c,num,noteOk,vel,decay, oscVal;
  Note Speech;
  OscMessage Transmit; 

  Flaps(int ix, int iy, int il, int ih, int ic,int inum, int ioscVal){
    x=ix;
    y=iy;
    l=il;
    h=ih;
    c=ic;
    num=inum;
    this.vel=127;
    this.decay=10;
    this.Speech=new Note(num,vel,decay);
    this.Transmit= new OscMessage("/module_Vue/FrameDif");
  }

  void display(){
    noFill();
    stroke(c,c,c);
    rect(x,y,l,h);
  }

  boolean overFlap(int piX, int piY) 
  {
    if (piX >= x && piX <= x+l && piY >= y && piY <= y+h) {
      return true;
    } 
    else {
      return false;
    }
  }

  void action(){
    noteOk=0;
    fill(255,0,0);
    stroke(255,0,0);
     ellipse(x,y+50,20,20);
    while(noteOk==0){
      if(noteOk==0){
        Transmit.add(oscVal);
        oscP5.send(Transmit, myRemoteLocation);
        midiOut.sendNote(Speech);
        noteOk=1;
        break;
      }
    }
    //  --> tester les valeurs de sortie OSC
    //println(oscVal);
  }

}

