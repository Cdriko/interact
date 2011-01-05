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
 * FlickrFeed
 *
 * This examples shows how to use romefeeder to get images from a Flickr feed,
 * and also demonstrate the use of callback to get more control over the processing
 * of feed entries.
 *
 * The feeder fetches Flickr images from a given feed, in this case a search for the
 * word "jackalope". The feeder takes care of continuously looking for new images with
 * the setUpdateInterval() and startUpdate() functions, and makes the new entries
 * available through the hasNext() and next() function which are used to get to the
 * actual entry objects.
 */
 
import net.obxlabs.romefeeder.*; //romefeeder
import com.sun.syndication.feed.synd.*; //ROME 
import java.util.List;

//array of thumbnail images loaded from flickr
PImage images[] = new PImage[50];
PImage shadow;
int thCount = 0;
int thPointer = 0;

//the tag to search flickr images for
static final String TAG = "nantes";

Feeder feeder;  // the feeder
SyndEntry entry; // feed entry

SyndContent content;  // content field of the xml entry
String photokey; // an image's photokey
List links;  // an image's links
ListIterator it;
SyndLink link = null;

void setup() {
  size(600, 300, P3D);
  frameRate(30);
  imageMode(CENTER);

  shadow = loadImage("shadow.png");

  //create the feeder 
  feeder = new Feeder();

  //turn on output to the console (default == false)
  feeder.verbose = true;

  //set the proxy for applets' limitations
  //make sure you copy the proxy.php provided with romefeeder to
  //the applet directory
  //feeder.setProxy("http://[urlToApplet]/FlickrFeed/applet/proxy.php");

  //load the feed  
  feeder.load("http://api.flickr.com/services/feeds/photos_public.gne?tags=" + TAG + "&amp;lang=en-us&amp;format=rss_200");

  //set the update interval to check for new posts in the loaded feed(s)
  feeder.setUpdateInterval(1*60*1000); // milliseconds
  
  //start updating
  feeder.startUpdate();
}

void draw() {
  //if there is another entry in the feeder and
  //we waited long enough since the last displayed entry then
  //display the next entry
  if (feeder.hasNext()) {
    //get the next entry
    entry = feeder.next();

    //extract the photokey from the content tag
    //this is used to build the urls to the different image sizes
    content = (SyndContent)entry.getContents().get(0);
    photokey = getPhotoKey(content.getValue());

    //get the link to the original image size
    //there are usually more than one link tag so parse for the
    //good one (enclosure)
    links = entry.getLinks();  
    it = links.listIterator();
    while(it.hasNext()) {
      link = (SyndLink)it.next();
      if (link.getRel().equals("enclosure")) {
        //load the image square thumbnail using the original url and photokey
        images[thCount] = loadImage(buildPhotoUrl(link.getHref(), photokey, "square"));
        //fill up the array and then stop looking
        if (++thCount >= images.length) {
          feeder.stopUpdate();          
          return;
        }
      }
    }
  }
  
  //draw the loaded images
  background(0);
  drawImages();
}

void drawImages() {

  //draw the shadows
  tint(255,255,255,75);
  for(int i = 0; i < thCount; i++) {
    pushMatrix();
    translate(i*width/(float)thCount, height/2 + 50, -cos(i/(float)thCount*TWO_PI)*100);
    rotateX(PI/2);
    image(shadow, 0, 0); 
    popMatrix();
  }  
  
  //draw the images
  noTint();
  for(int i = 0; i < thCount; i++) {
    pushMatrix();
    translate(i*width/(float)thCount, height/2, -cos(i/(float)thCount*TWO_PI)*100);
    image(images[i], 0, 0); 
    popMatrix();
  }  
}

//this function helps getting the photoKey of the thumbnails so that all
//the URLs are correct.  getPhotoKey  gets a chunk of the feed and extracts
//the keys and characters you need for the links
String getPhotoKey(String content) {
  int iHttp = content.indexOf("http://", content.indexOf("http://", content.indexOf("http://")));
  int iUnderscore = content.indexOf('_', iHttp)+1;
  return content.substring(iUnderscore, iUnderscore+10);
}

//
String buildPhotoUrl(String origUrl, String photoKey, String photoSize) {
  //map of size names to size postfixes
  HashMap sizes = new HashMap();
  sizes.put("square", "_s");
  sizes.put("thumbnail", "_t");
  sizes.put("small", "_m");
  sizes.put("medium", "");
  sizes.put("large", "_b");
  sizes.put("original", "_o");
		
  photoSize = photoSize.toLowerCase();
  if (!sizes.containsKey(photoSize))
    photoSize = "square";
    
  if (photoSize != "original")
    return origUrl.substring(0, origUrl.length()-16) + photoKey + sizes.get(photoSize) + ".jpg";
  else
    return origUrl;
}
