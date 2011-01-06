/**
 * Copyright 2008 OBX Labs / Bruno Nadeau / Jason Lewis
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/**
 * SelfTweet
 *
 * This examples shows how to use romefeeder to get tweets from Twitter,
 * and also demonstrate the use of callback to get more control over the
 * processing of feed entries.
 *
 * The feeder fetches tweets using a typical search query, in this case for
 * the word "self" and displays them. The query passed to the search function
 * is the same query you would enter in the search box on the Twitter site.
 * The feeder takes care of continuously looking for new tweets with the
 * setUpdateInterval() and startUpdate() functions, and makes the new entries
 * available through the hasNext() and next() function which are used to get
 * to the actual entry objects.
 *
 * The Feeder object provides a series of callbacks which can be used to
 * call functions at specific times during the process of syndicated entries.
 * In this case, the setLoadFeedCallback(...) function tells the feeder
 * object to call the postLoadFeed(...) function declared in the sketch when
 * a new feed is done loading for the first time. See documentation for more
 * callback functions.
 */

import net.obxlabs.romefeeder.*; //romefeeder
import com.sun.syndication.feed.synd.*; //ROME 

TwitterFeeder feeder;  // the feeder
boolean loaded = false; // flag that indicates if the search is loaded
int feedRate = 7*1000; // rate for displaying posts (in miliseconds)
int feedLast = 0;  // time of the last displayed post
SyndEntry entry; // feed entry
PFont font; // the font
static final int WORD_FONTSIZE = 128;  //self size
static final int TEXT_FONTSIZE = 24;   //rest of text size
static final int TEXT_WIDTH = 400;      //text width (in characters)

//search query
static final String QUERY = "self";
String topString = ""; //string of text that appears before 'self' in the tweet
String bottomString = ""; //string of text that appears after 'self' in the tweet

void setup() {
  size(600, 300);
  frameRate(30);
  smooth();
  
  //create and set the font
  font = createFont("bluehigh.ttf", 12, true);

  //add a loading prompt
  textFont(font, 24);
  text("Loading Tweets...", width/2, height/2);
  
  //create the feeder
  feeder = new TwitterFeeder();

  //turn on output to the console (default == false)
  feeder.verbose = true;

  //load entries and sort them by published date
  //default is unsorted, same as feed order  
  feeder.sort(Feeder.PUBLISHED_DATE);
  
  //set the proxy for applets' limitations
  //make sure you copy the proxy.php provided with romefeeder to
  //the applet directory
  //feeder.setProxy("http://[urlToApplet]/SelfTweet/applet/proxy.php");

  //set the feed load callback
  feeder.setLoadFeedCallback(
      new FeedCallback() { public void event(SyndFeed feed) { postLoadFeed(feed); } }
  );

  //load the feed  
  feeder.search(QUERY);
  
  //set the update interval to check for new posts in the loaded feed(s)
  feeder.setUpdateInterval(1*60*1000); // milliseconds
  
  //start updating
  feeder.startUpdate();
  
  //clear background
  background(0);
}

//flag when the search is done loading
void postLoadFeed(SyndFeed feed) {
  //flag as loaded
  loaded = true;
}

void draw() {
  //if the search is not done loading then wait
  if (!loaded) return;
  
  //overlay with semi-transparent background to create the shadowy effect
  background(0);
  
  //draw the searched text
  fill(255);
  stroke(0);
  textFont(font, WORD_FONTSIZE);
  textAlign(CENTER, CENTER);
  text(QUERY.toUpperCase(), width/2, height/2);

  //draw the rest of the tweet
  textFont(font, TEXT_FONTSIZE);
  fill(255);
  stroke(0);
  textAlign(LEFT, BOTTOM);
  text(topString, 205, -85, 350, 200);
  textAlign(RIGHT, TOP);
  text(bottomString, 50, height/2 + 54, 350, 190);
  
  //if there is another entry in the feeder and
  //we waited long enough since the last displayed entry then
  //display the next entry
  if ((feeder.hasNext()) && (millis()-feedLast >= feedRate)) {
    //get the next entry
    entry = feeder.next();
    
    //parse the entry title as text
    parseEntry(entry.getTitle());
    
    //update the feed timer
    feedLast = millis();
  }
}

//parses the tweet and stores the to strings
//that are displayed above and below the word 'self'.
void parseEntry(String title) {
  //make sure the magic word is there.
  if (title.toLowerCase().indexOf(QUERY) == -1) return;
  
  //get the strings before and after the magic word
  topString = title.substring(0, title.toLowerCase().indexOf(QUERY));
  bottomString = title.substring(title.toLowerCase().indexOf(QUERY) + QUERY.length());

  //clean up
  topString = topString.trim();
  bottomString = bottomString.trim();
}