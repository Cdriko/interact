Twitter twitter;
String myTimeline;
User[] friends;
String username = "julbel"; // add your own here
String password = "boites"; // add your own here
java.util.List statuses =null;

twitter = new Twitter(username,password);

try
{
Status status1 = twitter.update("Twitter avec Processing ça permet de relativiser");
}
catch( TwitterException e)  {
 println(e.getStatusCode());
}

