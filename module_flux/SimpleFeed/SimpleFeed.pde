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
 * SimpleFeed
 *
 * This example shows the simplest way to get data from a syndicated
 * feed (RSS or ATOM). The sketch fetches information from the feed
 * (http://feeds.thestranger.com/stranger/slog) and show entries'
 * titles sequentially. With the setUpdateInterval() and startUpdate()
 * functions, romeFeeder takes care of checking for new entries which
 * are then fetched using the hasNext() and next() functions of the 
 * Feeder.
 */

import net.obxlabs.romefeeder.*; //romefeeder
import com.sun.syndication.feed.synd.*; //ROME 

Feeder feeder;  // the feeder
int feedRate = 2*1000; // rate for displaying posts (in miliseconds)
int feedLast = 0;  // time of the last displayed post
SyndEntry entry; // feed entry

void setup() {
  size(600, 200);
  smooth();
  frameRate(30);
  
  //create and set the font
  PFont font = createFont("bluehigh.ttf", 12, true);
  textAlign(LEFT);

  //add a loading prompt
  textFont(font, 24);
  text("Loading...", 10, 10);

  //set the font size for the entries
  textFont(font, 52);
  
  //create the feeder
  feeder = new Feeder();

  //turn on output to the console
  feeder.verbose = true;

  //load entries and sort them by published date
  //default is unsorted, same as feed order  
  feeder.sort(Feeder.PUBLISHED_DATE);
  
  //set the proxy for applets' limitations
  //make sure you copy the proxy.php provided with romefeeder to
  //the applet directory
  //feeder.setProxy("http://[urlToApplet]/SimpleFeed/applet/proxy.php");

  //load the feed  
  feeder.load("http://feeds.thestranger.com/stranger/slog");
  
  //set the update interval to check for new posts in the loaded feed(s)
  feeder.setUpdateInterval(5*60*1000); // milliseconds
  
  //start updating
  feeder.startUpdate();
  
  //clear the background
  background(0);
}

void draw() {
  //overlay with semi-transparent background to create the shadowy effect
  fill(0, 0, 0, 20);
  noStroke();
  rect(0, 0, width, height);
 
  //if there is another entry in the feeder and
  //we waited long enough since the last displayed entry then
  //display the next entry
  if ((feeder.hasNext()) && (millis()-feedLast >= feedRate)) {
    //get the next entry
    entry = feeder.next();
    println(entry.getTitle());
    println(" + " + entry.getPublishedDate() + "\n");

    //update the feed timer
    feedLast = millis();
  }
  
  //draw the entry title on screen
  fill(250, int(random(190, 220)), 13, 150);
  stroke(62, 54, 21);
  if (entry != null)
    text(entry.getTitle(), 10, 10, width-50, height-20);
}
