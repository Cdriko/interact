// Basic example to retrieve data from an existing Pachube feed
//
// See many other methods available to the DataIn object here:
// http://www.eeml.org/library/docs/eeml/DataIn.html


import eeml.*;

DataIn dIn;

PFont font;

void setup(){
  size(800,600,P3D);
 // frameRate(15);

font = loadFont("Arial-Black-20.vlw"); 
textFont(font);


  background(0);
    // set up DataIn object; indicate the URL you want, your Pachube API key, and how often you want it to update
    // e.g. every 15 seconds    
 //   dIn = new DataIn(this,"http://www.pachube.com/api/504.xml", "798395b56b38f5b0379ed672855c7b17e2d8056f06f928fbc05fdcb87b9b8abe", 1000);
   dIn = new DataIn(this,"http://www.pachube.com/api/7018.xml", "798395b56b38f5b0379ed672855c7b17e2d8056f06f928fbc05fdcb87b9b8abe", 1000);
   // dIn = new DataIn(this,"http://www.pachube.com/api/9309.xml", "798395b56b38f5b0379ed672855c7b17e2d8056f06f928fbc05fdcb87b9b8abe", 5000);
}

void draw()
{
  
}

// onReceiveEEML is run every time your app receives back EEML that it has requested from a Pachube feed. 
void onReceiveEEML(DataIn d){ 

 
    float myVariable1 = d.getValue(1); 
    float myVariable2 = d.getValue(0); // get the value of the stream 1
    println(myVariable1);
    println(myVariable2);
    background(0);

    fill(255);
    rect(myVariable1/4,myVariable1/4,100,100);
    text(myVariable1, 120,100);
    fill(200);
    rect(myVariable2/4,myVariable2/4,100,100);
    text(myVariable2, 220,100);
}
