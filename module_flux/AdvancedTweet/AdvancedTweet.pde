/**
 * Copyright 2009 Obx Labs / Bruno Nadeau / Jason Lewis
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
 */

/**
 * AdvancedTweet
 *
 * This examples shows how to use romefeeder to get tweets from Twitter
 * using the advanced search feature of the Feeder. It also demonstrates
 * the use of callback to get more control over the processing of feed
 * entries.
 *
 * The feeder fetches tweets using the advanced search query, in this case for
 * the word "master" and displays them. The values of the search query are set
 * first, then the search function is called. The feeder takes care of
 * continuously looking for new tweets with the setUpdateInterval() and
 * startUpdate() functions, and makes the new entries available through the
 * hasNext() and next() function which are used to get to the actual entry\
 * objects.
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
static final String ANDS = "nantes";
static final String LANG = "fr";
static final boolean QUESTION = true;
static final String NOTS = "thesis";
static final int RPP = 50;

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

  //setup and query the search
  feeder.all(ANDS);  //get tweets with the word master
  feeder.not(NOTS);     //exclude the tweets with the word thesis
  feeder.lang(LANG);     //get only tweets in english
  feeder.question(QUESTION);  //get tweets that are ot have questions
  feeder.rpp(RPP);  //get 50 tweets at a time
  feeder.search();
  
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
  text(ANDS.toUpperCase(), width/2, height/2);

  //draw the rest of the tweet
  textFont(font, TEXT_FONTSIZE);
  fill(255);
  stroke(0);
  textAlign(LEFT, BOTTOM);
  text(topString, 105, -85, 350, 200);
  textAlign(RIGHT, TOP);
  text(bottomString, 150, height/2 + 54, 350, 190);
  
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
  if (title.toLowerCase().indexOf(ANDS) == -1) return;
  
  //get the strings before and after the magic word
  topString = title.substring(0, title.toLowerCase().indexOf(ANDS));
  bottomString = title.substring(title.toLowerCase().indexOf(ANDS) + ANDS.length());

  //clean up
  topString = topString.trim();
  bottomString = bottomString.trim();
}
