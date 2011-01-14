Twitter myTwitter;

void setup() {
  
  size(800,400);
//  f = loadFont("Abecedario-20.vlw");        
  myTwitter = new Twitter("julbel", "Sardine$");
  background(0); 
  
};

void draw(){
try
{
Status status1 = myTwitter.update("convocation à un entretien de suivi de votre projet personnalié d'accès à l'emploi");
}
catch( TwitterException e)  {
 println(e.getStatusCode());
}
};

