Twitter myTwitter;


PFont f;           // Variable to hold onto a font

void setup() {
  
  size(800,400);
    f = loadFont("Abecedario-20.vlw");        
  myTwitter = new Twitter("julbel", "boites");
        background(0); 
  
};

void draw() {
  try {

    Query query = new Query("labtolab");
    query.setRpp(100);
    QueryResult result = myTwitter.search(query);

    ArrayList tweets = (ArrayList) result.getTweets();

    for (int i = 0; i < tweets.size(); i++) {
      Tweet t = (Tweet) tweets.get(i);
      String user = t.getFromUser();
      String msg = t.getText();
      Date d = t.getCreatedAt();
      println("Tweet by " + user + " at " + d + ": " + msg);
        textFont(f);
   
  fill(255);
  text("Tweet by " + user + " at " + d + ": " + msg,random(400),random(400));
    
    };

  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  };

};

