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
Status status1 = myTwitter.update("Twitter avec Processing ça permet de relativiser");
}
catch( TwitterException e)  {
 println(e.getStatusCode());
}
};

