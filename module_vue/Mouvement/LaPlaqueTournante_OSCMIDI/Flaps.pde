class Flaps {
  int x,y,l,h,c,num,noteOk,vel,pitch, oscVal;
  //Note Speech;
  OscMessage Transmit; 
  Rectangle me;

  Flaps(int ix, int iy, int il, int ih, int ic,int inum, int ioscVal) {
    x=ix;
    y=iy;
    l=il;
    h=ih;
    c=ic;
    num=inum;
    me=new Rectangle(x,y,l,h);
    this.vel=127;
    this.pitch=num;

    this.Transmit= new OscMessage("/module_Vue/FrameDif");
  }

  void display() {
    noFill();
    stroke(c,c,c);
    rect(x,y,l,h);
  }



  boolean intersect(Rectangle visitor) {      
    return me.intersects(visitor);
  }

  void action() {
    noteOk=0;
    fill(x,250-x,0);
    stroke(255,0,0);
    ellipse(x,y+50,20,20);
    while(noteOk==0) {
      if(noteOk==0) {
        Transmit.add(oscVal);
        oscP5.send(Transmit, myRemoteLocation);
        midiOut.sendNoteOn(0, this.pitch, this.vel);
        //midiOut.sendNote(Speech);
        noteOk=1;
        break;
      }
    }
    //  --> tester les valeurs de sortie OSC
    //println(oscVal);
  }
}

