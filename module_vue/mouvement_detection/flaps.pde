class Flaps {
  int x,y,l,h,num,noteOk,vel,decay;
  int pitch, oscVal;
  OscMessage Transmit; 
  Rectangle me;
  color c;

  Flaps(int ix, int iy, int il, int ih, color ic,int inum, int ioscVal) {
    x=ix;
    y=iy;
    l=il;
    h=ih;
    c=ic;
    num=inum;
    me = new Rectangle(x-(l/2), y-(h/2), l, h);
    this.vel=127;
    this.decay=10;
    this.pitch=num;
    this.Transmit = new OscMessage("/module_Vue/FrameDif");
  }
  void display() {
    noFill();
    strokeWeight(2);
    stroke(c);
    rect(x-(l/2),y-(h/2),l,h);
  }

  boolean intersect(Rectangle visitor) {  
    return me.intersects(visitor);
  }

  void action() {
    noteOk=0;
    fill(255,0,0);
    stroke(255,0,0);

    ellipse(x,y,20,20);
    while(noteOk==0) {
      if(noteOk==0) {
        Transmit.add(oscVal);
        oscP5.send(Transmit, myRemoteLocation);
        midiOut.sendNoteOn(0, this.pitch, this.vel);
        noteOk=1;
        break;
      }
    }
  }
}

