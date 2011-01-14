/**
 * monCanalOSCbroadcastClient by andreas schlegel
 * an osc broadcast client.
 * an example for broadcast server is located in the monCanalOSCbroadcaster exmaple.
 * monCanalOSC website at http://www.sojamo.de/monCanalOSC
 */

// importation des librairies
import oscP5.*;
import netP5.*;

// on déclare une instance OSC -> un canal de communication OSC, on l'appelle "monCanalOSC"
OscP5 monCanalOSC;

// déclaration d'une adresse IP et du numero du port utilisé pour la communication en direction du serveur sur le reseau
NetAddress myBroadcastLocation; 


// initialisation du programme
void setup() {
  size(400,400);
  frameRate(25);
  
  //on crée une instance de MonCanalOSC et on lui attribue 2 valeurs : this = l'objet actuellement traité, 12000 = le numero du port.
   
  monCanalOSC = new OscP5(this,12000);
  
  // on crée une nouvelle adresse correspondant au serveur receptionnant les messages OSC.
  
  // l'adresse du serveur 
  myBroadcastLocation = new NetAddress("127.0.0.1",12000);
}

// la boucle du programme
void draw() {
  background(0);
}

// lorsqu'on appui sur la souris
void mousePressed() {

  // on crée un nouveau message avec une adresse type, dans ce cas /test.
  OscMessage myOscMessage = new OscMessage("/test");
  // on ajoute une variable à ce message, ici un int d'une valeur 100
  myOscMessage.add(100);
  //on envoi le message à l'adresse spécifiée dans l'objet myNetAddress
  monCanalOSC.send(myOscMessage, myBroadcastLocation);
}


void keyPressed() {
  OscMessage m;
  switch(key) {
    case('c'):
      /* pour se connecter au serveur */
      m = new OscMessage("/server/connect",new Object[0]);
      monCanalOSC.flush(m,myBroadcastLocation);  
      break;
    case('d'):
      /* se deconnecter du serveur */
      m = new OscMessage("/server/disconnect",new Object[0]);
      monCanalOSC.flush(m,myBroadcastLocation);  
      break;

  }  
}

// methode permettant de receptionner les messages osc entrants
void oscEvent(OscMessage theOscMessage) {

  // recupere et affiche l'adresse et le type de message reçu
  println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  theOscMessage.print();
}
