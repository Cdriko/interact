/*
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

package net.obxlabs.romefeeder;

import java.net.*;
import java.util.*;
import java.io.*;

import com.sun.syndication.feed.synd.*;
import com.sun.syndication.io.*;

/**
 * Feed manager.
 * <p>The feeder allows to load and update one or multiple syndicated feeds
 * using the <a href="https://rome.dev.java.net/">ROME</a> library. It provides sorting 
 * functions to view the loaded entries in different orders, and it includes a simple
 * way to load feeds through a PHP web proxy.</p>
 * 
 * @author Bruno Nadeau
 */
public class Feeder implements Runnable {

	//
	// Feeds and Entries
	//
	
	/** Queued feeds. */
	private ArrayList feedQueue = new ArrayList();
	
	/** Loaded feeds. */
	private HashMap feeds = new HashMap();
	
	/** Loaded entries. */
	private LinkedList entries = new LinkedList();
	
	/** Entry pointer. */
	private int index = -1;

	//
	// Sorting
	//
	
	/** Sort options: unsorted (default). */
	public static final int UNSORTED = 0;
	
	/** Sort option: published date. */
	public static final int PUBLISHED_DATE = 1;
	
	/** Sort option: updated date. */
	public static final int UPDATED_DATE = 2;
	
	/** Sort option: title. */
	public static final int TITLE = 3;
	
	/** Sort entries by. */
	private int sortBy = UNSORTED;
	
	//
	// Updating
	//
	
	/** Loading/Updating thread. */
	private Thread lThread = null;
	
	/** Updating. */
	private boolean updating = false;
	
	/** Time of last update. */
	private long lastUpdate = 0;
	
	/** Update interval. */
	private long updateInterval = 1*60*1000; // 1min
	
	//
	// Callbacks
	//
	
	/** Callback before a feed is loaded. */
	public FeedCallback preloadFeedCallback = null;
	
	/** Callback after a feed is loaded. */
	public FeedCallback postloadFeedCallback = null;
	
	/** Callback before a feed is updated. */
	public FeedCallback preupdateFeedCallback = null;
	
	/** Callback after a feed is updated. */
	public FeedCallback postupdateFeedCallback = null;
	
	/** Callback before feeds are updated. */
	public FeedCallback preupdateGlobalCallback = null;
	
	/** Callback after feeds are updated. */
	public FeedCallback postupdateGlobalCallback = null;
	
	/** Callback before an entry is loaded. */
	public EntryCallback preloadEntryCallback = null;	
	
	/** Callback after an entry is loaded. */
	public EntryCallback postloadEntryCallback = null;	

	//
	// Proxy (use with applet)
	//
	
	/** Proxy. */
	private String proxy = null;
	
	//
	// Debugging
	//
	
	/** Outputs process information when true. */
	public boolean verbose = false;
	
	/**
	 * Create an empty Feeder.
	 */
	public Feeder() {
		//create the thread that manages feeds
		lThread = new Thread(this, "Feeder");
		
		//start the thread
		try {
			lThread.start();
		} catch(IllegalThreadStateException ex) {
			//exception if the thread is already started
			//this should never happen and is there just for completeness
			err("Feeder thread could not start. Make sure the Feeder constructor is called correctly.");
		}
			
		//save current time to time the next update
		lastUpdate = System.currentTimeMillis();
	}
	
	/**
	 * Create a Feeder and load a Feed from a given xml file or url.
	 * @param xml url or file path
	 */
	public Feeder(String xml) {
		this();
		
		//load the xml feed
		load(xml);
	}
	
	/**
	 * Set the sorting value for loading entries
	 * <p>This must be called before any entry is added to the feeder.
	 * @param value value to sort entries by (UNSORTED, PUBLISHED_DATE, UPDATED_DATE, TITLE)
	 */
	public void sort(int value) {
		//make sure this is called before anything is loaded 
		if (count() > 0) {
			//output warning
			String msg = "sort() must be called before any entry is loaded. ";
			switch(sortBy) {
			case UNSORTED:
				msg += "Not sorting.";
				break;
			case PUBLISHED_DATE:
				msg += "Sorting by published date.";
				break;
			case UPDATED_DATE:
				msg += "Sorting by updated date.";
				break;
			case TITLE:
				msg += "Sorting by title.";
				break;
			}		
			err(msg);
			return;
		}
		
		//set the sort value
		sortBy = value;
		
		//output change
		String msg = "";
		switch(sortBy) {
		case UNSORTED:
			msg = "Not sorting.";
			break;
		case PUBLISHED_DATE:
			msg = "Sorting by published date.";
			break;
		case UPDATED_DATE:
			msg = "Sorting by updated date.";
			break;
		case TITLE:
			msg = "Sorting by title.";
			break;
		}	
		out(msg);
	}
	
	/**
	 * Set the proxy used to fetch external feeds.
	 * @param proxy the url of the proxy
	 */
	public void setProxy(String proxy) {
		//make sure we don't have an empty string
		if ((proxy != null) && (proxy.length() == 0)) proxy = null;
		
		//set the proxy
		this.proxy = proxy;
		
		//output change
		out("Using proxy '" + this.proxy + "'.");
	}
	
	/**
	 * Load a Feed from a given xml file or url and uses the feed's path as id. 
	 * @param xml url or file path
	 */
	public void load(String xml) {
		//add the feed to the queue
		synchronized(feedQueue) {
			feedQueue.add(xml);
		}
		
		//output queued feed
		out("Queued '" + xml + "'");
	}

	/**
	 * Set the post load callback.
	 * @deprecated Replaced by setLoadFeedCallback
	 * @param postloadCallback
	 */
	public void setLoadCallback(FeedCallback postloadCallback) {
		setLoadCallback(null, postloadCallback);
	}	
		
	/**
	 * Set the post load feed callback.
	 * <p>Sets a FeedCallback object that will be called right
	 * AFTER a feed is loaded.</p>
	 * @param postloadFeedCallback
	 */
	public void setLoadFeedCallback(FeedCallback postloadFeedCallback) {
		setLoadFeedCallback(null, postloadFeedCallback);
	}
	
	/**
	 * Set the pre and post load callbacks.
	 * @deprecated Replaced by setLoadFeedCallback
	 * @param preloadCallback
	 * @param postloadCallback
	 */
	public void setLoadCallback(FeedCallback preloadCallback, FeedCallback postloadCallback) {
		this.preloadFeedCallback = preloadCallback;
		this.postloadFeedCallback = postloadCallback;
	}
	
	/**
	 * Set the pre and post load feed callbacks.
	 * <p>Sets a FeedCallback object that will be called right
	 * BEFORE and another object that will be called right AFTER
	 * a feed is loaded.</p>
	 * @param preloadFeedCallback
	 * @param postloadFeedCallback
	 */
	public void setLoadFeedCallback(FeedCallback preloadFeedCallback, FeedCallback postloadFeedCallback) {
		this.preloadFeedCallback = preloadFeedCallback;
		this.postloadFeedCallback = postloadFeedCallback;
	}

	/**
	 * Set the post update callback.
	 * @deprecated Replaced by setUpdateFeedCallback
	 * @param postupdateCallback
	 */
	public void setUpdateCallback(FeedCallback postupdateCallback) {
		setUpdateCallback(null, postupdateCallback);
	}
	
	/**
	 * Set the post update feed callback.
	 * <p>Sets a FeedCallback object that will be called right
	 * AFTER each time a feed is updated.</p>
	 * @param postupdateFeedCallback
	 */
	public void setUpdateFeedCallback(FeedCallback postupdateFeedCallback) {
		setUpdateFeedCallback(null, postupdateFeedCallback);
	}
	
	/**
	 * Set the post update callback.
	 * @deprecated Replaced by setUpdateFeedCallback
	 * @param preupdateCallback
	 * @param postupdateCallback
	 */
	public void setUpdateCallback(FeedCallback preupdateCallback, FeedCallback postupdateCallback) {
		this.preupdateFeedCallback = preupdateCallback;
		this.postupdateFeedCallback = postupdateCallback;		
	}
	
	/**
	 * Set the post update feed callback.
	 * <p>Sets a FeedCallback object that will be called right
	 * BEFORE and another object that will be called right AFTER
	 * each time a feed is updated.</p>
	 * @param preupdateFeedCallback
	 * @param postupdateFeedCallback
	 */
	public void setUpdateFeedCallback(FeedCallback preupdateFeedCallback, FeedCallback postupdateFeedCallback) {
		this.preupdateFeedCallback = preupdateFeedCallback;
		this.postupdateFeedCallback = postupdateFeedCallback;		
	}

	/**
	 * Set the post load entry callback.
	 * <p>Sets an EntryCallback object that will be called right
	 * AFTER an entry is loaded.</p>
	 * @param postloadEntryCallback
	 */
	public void setLoadEntryCallback(EntryCallback postloadEntryCallback) {
		setLoadEntryCallback(null, postloadEntryCallback);
	}
	
	/**
	 * Set the pre and post load entry callbacks.
	 * <p>Sets an EntryCallback object that will be called right
	 * BEFORE and another object that will be called right AFTER
	 * an entry is loaded.</p>
	 * @param preloadEntryCallback
	 * @param postloadEntryCallback
	 */
	public void setLoadEntryCallback(EntryCallback preloadEntryCallback, EntryCallback postloadEntryCallback) {
		this.preloadEntryCallback = preloadEntryCallback;
		this.postloadEntryCallback = postloadEntryCallback;
	}
	
	/**
	 * Load the oldest feed added to the queue.
	 */
	private void processQueue() {
		synchronized(feedQueue) {
			//if the queue is not empty
			//load the oldest feed (fifo)
			if (feedQueue.size() > 0) {
				loadEntries((String)feedQueue.remove(0));
			}
		}
	}
	
	/**
	 * Read a Feed from a given xml file or url.
	 * @param xml url or file path
	 * @return feed
	 */
	private SyndFeed read(String xml) {
		//the feed object
		SyndFeed feed = null;
		
		//try it as a url first
		try {
			URL url = new URL(xml);
			feed = readFromURL(xml);
		}
		//if the url doesn't work then it might be a file
		catch(MalformedURLException mue) {
			feed = readFromFile(xml);
		}
		//if it's another exception then we can't read the feed
		catch(Exception e) {
			//output warning
			err("Exception when reading feed '" + xml + "' (" + e.getMessage() + ").");  
		}
		
		//return the feed
		return feed;
	}
	
	/**
	 * Load a feed from a URL.
	 * @param xml the url
	 * @return feed
	 */
	private SyndFeed readFromURL(String xml) {
		//the feed object
		SyndFeed feed = null;
		
		//load the feed from url
		try {
			//read the feed using proxy if it is set
			if (proxy == null)
				feed = new SyndFeedInput().build(new XmlReader(new URL(xml)));
			else {
				String parsedXml = xml.replace('?', '&');
				URL url = new URL(proxy + "?url=" + parsedXml);
				feed = new SyndFeedInput().build(new XmlReader(url));
			}
		} catch(Exception e) {
			//output error
			err("Unable to load feed '" + xml + "' (" + e.getMessage() + ").");
		}
		
		//return the feed
		return feed;
	}
	
	/**
	 * Load a feed from a local file.
	 * @param xml the file path
	 * @return feed
	 */
	private SyndFeed readFromFile(String xml) {
		//the feed object
		SyndFeed feed = null;
		
		//load the feed from file
		try {
			//read the feed
			feed = new SyndFeedInput().build(new XmlReader(new File(xml)));
		} catch(Exception e) {
			//output error
			err("Unable to load feed '" + xml + "' (" + e.getMessage() + ").");
		}
		
		//return the feed
		return feed;
	}
	
	/**
	 * Load the entries of a feed into the sorted list of entries.
	 * @param xml url or file path
	 */
	private void loadEntries(String xml) {
		//output that we are load
		out("Loading feed '" + xml + "'...");
		
		//read the feed
		SyndFeed feed = read(xml);
		
		//make sure the feed is loaded correctly
		if (feed == null) {
			//output error
			err("Unable to load feed '" + xml + "'.");
			return;
		}
		
		//call the preload feed callback
		if (preloadFeedCallback != null)
			preloadFeedCallback.event(feed);
		
		//add the feed to the list of feed to keep track
		synchronized(feeds) {
			feeds.put(xml, feed);
		}
		
		//keep track of the number of entries
		int count = entries.size();
		
		//load the feed's entries
		loadEntries(feed);

		//call the postload feed callback
		if (postloadFeedCallback != null)
			postloadFeedCallback.event(feed);
		
		//output the new entries
		out("Done loading. Found " + (entries.size()-count) + " new entries.");
	}
	
	/**
	 * Load the entries of a feed into the sorted list of entries.
	 * @param feed
	 */
	private void loadEntries(SyndFeed feed) {
		//make sure the feed is valid
		if (feed == null) return;
		
		//get the feed's entry list
		List entries = feed.getEntries();
		
		//go through the entries and load one by one
		//the entries are loaded backwards so that they appear
		//in the right order when unsorted
		SyndEntry entry;
		for (int i = entries.size()-1; i >= 0; i--) {
			//get the next entry
			entry = (SyndEntry)entries.get(i);
			
			//call the preload entry callback
			if (preloadEntryCallback != null)
				preloadEntryCallback.event(entry, feed);
				
			//load the entry
			loadEntry(entry);

			//call the postload entry callback
			if (postloadEntryCallback != null)
				postloadEntryCallback.event(entry, feed);				
		}
	}
	
	/**
	 * Load an entry into the list.
	 * @param entry
	 */
	private void loadEntry(SyndEntry entry) {
		//make sure the entry is valid
		if (entry == null) return;
		
		//add the entry to the list based on the sorting value
		//TODO: optimize sorting technique
		switch(sortBy) {
			case UNSORTED:
				//unsorted adds the entry at the end of the list
				synchronized(entries) {
					entries.add(entry);
				}
				return;
			case PUBLISHED_DATE:
				//if we are sorting by published date then make sure its present
				//if not then load as unsorted
				if (entry.getPublishedDate() == null) {
					err("Entry '" + entry.getTitle() + "' does not have a published date. Unable to sort it.");
					synchronized(entries) {
						entries.add(entry);
					}					
					return;
				}
				break;
			case UPDATED_DATE:
				//if we are sorting by updated date then make sure its present
				//if not then load as unsorted
				if (entry.getUpdatedDate() == null) {
					err("Entry '" + entry.getTitle() + "' does not have an updated date. Unable to sort it.");
					synchronized(entries) {
						entries.add(entry);
					}					
					return;
				}
				break;
			case TITLE:
				//if we are sorting by title then make sure its present
				//if not then load as unsorted
				if (entry.getTitle() == null) {
					err("Entry '" + entry.getTitle() + "' does not have a title. Unable to sort it.");
					synchronized(entries) {
						entries.add(entry);
					}					
					return;
				}
				break;
		}
		
		//loop through the loaded entries and insert the new one
		//at the correct position based on sorting value
		SyndEntry se;
		for(int i = 0; i < entries.size(); i++) {
			//get the next entry
			se = (SyndEntry)entries.get(i);
			
			//insert entry in the list
			synchronized(entries) {
				switch(sortBy) {
					case PUBLISHED_DATE:
						//if the entry from the list doesn't have a published date
						//then we just skip it
						if (se.getPublishedDate() == null) continue;
						
						//insert the entry if the new entry date is before the one stored
						if (entry.getPublishedDate().compareTo(se.getPublishedDate()) < 0) {
							entries.add(i, entry);
							
							//adjust the pointer if the entry was inserted before it
							if (i <= index) index++;
							return;
						}
						break;
					case UPDATED_DATE:
						//if the entry from the list doesn't have an updated date
						//then we just skip it
						if (se.getUpdatedDate() == null) continue;
						
						//insert the entry if the new entry date is before the one stored
						if (entry.getUpdatedDate().compareTo(se.getUpdatedDate()) < 0) {
							entries.add(i, entry);
							
							//adjust the pointer if the entry was inserted before it
							if (i <= index) index++;
							return;
						}
						break;
					case TITLE:
						//if the entry from the list doesn't have a title
						//then we just skip it
						if (se.getTitle() == null) continue;
						
						//insert the entry if the new entry title is before the one stored
						if (entry.getTitle().toLowerCase().compareTo(se.getTitle().toLowerCase()) < 0) {
							entries.add(i, entry);
							
							//adjust the pointer if the entry was inserted before it
							if (i <= index) index++;
							return;
						}
						break;
				}
			}
		}
		
		//if we reach this then we hit the end of the list
		//so add the new entry at the end
		synchronized(entries) {
			entries.add(entry);
		}
	}
	
	/**
	 * Get the loaded Feed with a given id. Returns NULL if
	 * no Feed was loaded with the id.
	 * @param xml url or file path
	 * @return feed
	 */
	public SyndFeed getFeed(String xml) {
		//get the feed that matches the id, usually the xml url or filepath
		return (SyndFeed)feeds.get(xml);
	}
	
	/**
	 * Remove the loaded Feed with a given id.
	 * @param xml url or file path
	 * @return removed feed
	 */
	public SyndFeed removeFeed(String xml) {
		//remove the feed that matches the id, usually the xml url or filepath
		synchronized(feeds) {
			return (SyndFeed)feeds.remove(xml);
		}
	}
	
	/**
	 * Remove the loaded Feed.
	 * @param feed
	 */
	public SyndFeed removeFeed(SyndFeed feed) {
		//remove the feed
		synchronized(feeds) {
			//go through the loaded feeds and remove the one that matches, if any		
			Iterator iterator = feeds.entrySet().iterator();
			SyndFeed f;
			while (iterator.hasNext()) {
				f = (SyndFeed)iterator.next();
				if (f == feed) {
					iterator.remove();
					
					//output change
					if (feed.getTitle() == null)
						out("Removed feed.");
					else
						out("Removed feed '" + feed.getTitle() + "'");
					
					return f;
				}
			}
		}

		//output error
		if (feed.getTitle() == null)
			err("Feed not found. Could not remove feed.");
		else
			err("Feed not found. Could not remove feed '" + feed.getTitle() + "'.");
		
		return null;
	}
	
	/**
	 * Return the number of loaded feeds.
	 * @return number of loaded feed.
	 */
	synchronized public int countFeeds() {
		//return the loaded feed count
		return feeds.size();
	}
	
	/**
	 * Return the number of loaded entries.
	 * @return number of loaded entries
	 */
	public int count() {
		//return the loaded entry count
		return entries.size();
	}
	
	/**
	 * Check if there is more entries in the list.
	 * @return true if feeder has more entries
	 */
	public boolean hasNext() {
		//return true if the pointer is not at the end
		return index < entries.size()-1;
	}
	
	/**
	 * Get the next entry in the list.
	 * @return the next entry in the list
	 */
	public SyndEntry next() {
		//if the pointer is not at the end then return
		//the next entry in the list and advance the pointer
		synchronized(entries) {
			if (hasNext()) 
				return (SyndEntry)entries.get(++index);
		}
		
		//we reached the end
		return null;
	}
	
	/**
	 * Get the last entry in the list and move the pointer to it.
	 */
	public SyndEntry last() {
		//if the list of loaded entries is not empty
		//then get the last one loaded and move the pointer
		//to the end.
		synchronized(entries) {
			if (!entries.isEmpty()) 
				return (SyndEntry)entries.get(index = (entries.size()-1));
		}
		
		//entry list was empty
		return null;		
	}

	/**
	 * Reset the list iterator of the entries.
	 */
	public void reset() {
		//reset the pointer
		index = -1;
	}
	
	/**
	 * Clear the feeder.
	 */
	synchronized public void clear() {
		//clear the list of feeds to load
		feedQueue.clear();
		
		//reset the pointer
		reset();
		
		//clear the list of loaded entries
		entries.clear();
		
		//clear the list of loaded feeds
		feeds.clear();
	}
	
	/**
	 * Start updating loaded feeds.
	 */
	public void startUpdate() {	
		//turn on updating flag
		updating = true;
		
		//output change
		out("Start updating (" + updateInterval + "ms).");		
	}

	/**
	 * Start updating loaded feeds and set global post update callbacks.
	 */
	public void startUpdate(FeedCallback postupdateGlobalCallback) {
		//start update and set the postupdate callback and no preupdate callback
		startUpdate(null, postupdateGlobalCallback);
	}
	
	/**
	 * Start updating loaded feeds and set global update callbacks.
	 */
	public void startUpdate(FeedCallback preupdateGlobalCallback, FeedCallback postupdateGlobalCallback) {
		//set callbacks
		this.preupdateGlobalCallback = preupdateGlobalCallback;
		this.postupdateGlobalCallback = postupdateGlobalCallback;

		//turn on updating flag
		updating = true;

		//output change
		out("Start updating (" + updateInterval + "ms).");
	}
	
	/**
	 * Stop updating loaded feeds.
	 */
	public void stopUpdate() {	
		//turn on updating flag
		updating = false;
		
		//output change
		out("Stop updating.");		
	}
	
	/**
	 * Set the interval between updates.
	 * @param ui interval in milliseconds
	 */
	public void setUpdateInterval(long ui) {
		//the interval must be positive
		if (ui < 0) {
			//output warning
			err("Update interval can not be negative.");
			
			//set to zero
			ui = 0;
		}
		
		//setting the update interval
		updateInterval = ui;
		
		//output change
		out("Setting update interval to " + ui + "ms.");
	}
	
	/**
	 * Get the update interval.
	 * @return update interval
	 */
	public long getUpdateInterval() { return updateInterval; }
	
	/**
	 * Fetches the new entries from the loaded feeds.
	 */
	private void update() {
		//call the preupdate callback
		if (preupdateGlobalCallback != null)
			preupdateGlobalCallback.event(null);
		
		//go through all the loaded feeds and fetch new entries
		synchronized(feeds) {
			Iterator ite = feeds.keySet().iterator();
			String xml;
			while (ite.hasNext()) {
				//get the next xml
				xml = (String)ite.next();
				
				//update the feed
				updateFeed(xml);
			}
		}
		
		//call the postupdate callback
		if (postupdateGlobalCallback != null)
			postupdateGlobalCallback.event(null);
	}
	
	/**
	 * Fetches the new entries from a feed.
	 * @param xml url or file path to feed
	 */
	private void updateFeed(String xml) {
		//get the feed object from the list
		SyndFeed feed = (SyndFeed)feeds.get(xml);
		
		//make sure the feed exists
		if (feed == null) { return; }
		
		//preupdate callback
		if (preupdateFeedCallback != null)
			preupdateFeedCallback.event(feed);

		//output as updating
		if (feed.getTitle() == null)
			out("Updating (" + xml + ")...");
		else
			out("Updating (" + feed.getTitle() + ")...");

		//get the most recent entry date
		//anything posted after that will be added to the list
		Date mostRecentDate = getMostRecentDate(feed);
		
		//make sure we found a date
		if (mostRecentDate == null) {
			err("Unable to update feed ('" + xml + "'). Entries do not have any dates. Updater ain't happy.");
			return;
		}
		
		//reload the feed
		feed = read(xml);
		
		//make sure the feed is loaded correctly
		if (feed == null) {
			err("Unable to update feed ('" + xml + "').");
			return;
		}
		
		//replace with the newly updated feed in the list
		synchronized(feeds) {
			feeds.put(xml, feed);
		}

		//keep track of the number of entries
		int count = this.entries.size();
		
		//load the entries that are newer than the most recent one in the list
		//TODO: This might fail to load some entries, like entries that are dated older
		//than the current date and time they are posted when added to the feed.
		SyndEntry entry;
		boolean passedMostRecent = false;
		List entries = feed.getEntries();
		for (int i = entries.size()-1; i >= 0; i--) {
			//get the next entry
			entry = (SyndEntry)entries.get(i);
			
			//if the entry doesn't have a date then we only
			//add it if we passed the mostRecenly loaded entry
			if ((entry.getUpdatedDate() == null) && (entry.getPublishedDate() == null)) {
				err("Unable to process entry. Updater does not cope well with entries that are not dated. Let us know if you need this.");
				continue;
			}

			//insert entry if it is newer than the most recent one
			if ((entry.getUpdatedDate() != null) &&
				(entry.getUpdatedDate().compareTo(mostRecentDate) > 0)) {
				loadEntry(entry);
			} 
			else if ((entry.getPublishedDate() != null) &&
					(entry.getPublishedDate().compareTo(mostRecentDate) > 0)) {
				loadEntry(entry);
			}
		}

		//output done
		if (feed.getTitle() == null)
			out("Done updating (" + xml + "). Found " + (this.entries.size()-count) + " new entries.");
		else
			out("Done updating (" + feed.getTitle() + "). Found " + (this.entries.size()-count) + " new entries.");
		
		//call the postupdate callback
		if (postupdateFeedCallback != null)
			postupdateFeedCallback.event(feed);
	}

	/**
	 * Get the most recent date of the entries of a feed.
	 */
	Date getMostRecentDate(SyndFeed feed) {
		//get the entries and loop through them all to find
		//the most recent date
		List entries = feed.getEntries();
		Date mostRecent = null;
		SyndEntry entry;
		Date updated = null;
		Date published = null;
		for (int i = 0; i < entries.size(); i++) {
			//get the next entry
			entry = (SyndEntry)entries.get(i);

			//get the dates
			updated = entry.getUpdatedDate();
			published = entry.getPublishedDate();
	
			//check the updated date
			if (updated != null) {
				if ((mostRecent == null) || (updated.compareTo(mostRecent) > 0))
					mostRecent = updated;
			}
			//check the published date
			else if (published != null) {
				if ((mostRecent == null) || (published.compareTo(mostRecent) > 0))
					mostRecent = published;			
			}
		}
		
		return mostRecent;
	}
	
	/**
	 * Main function of the loading/updating thread.
	 */
	public void run() {
		//loop infinitely
		while (true) {
			//load queued feeds
			processQueue();
	
			//update at interval
			if (updating && (System.currentTimeMillis() > lastUpdate+updateInterval)) {
				//update
				update();
				
				//set the latest updating time
				lastUpdate = System.currentTimeMillis();
			}
	
			//sleep
			try {
				Thread.sleep(100);
			} catch (InterruptedException ie) {
				err("Feeder loader was interrupted (" + ie.getMessage() + ").");
			}
		}
    }
	
	/**
	 * Outputs errors to the console.
	 */
	public void err(String msg) {
		if (verbose) System.err.println("romeFeeder: " + msg);
	}
	
	/**
	 * Outputs text to the console.
	 */
	public void out(String msg) {
		if (verbose) System.out.println("romeFeeder: " + msg);
	}
}
