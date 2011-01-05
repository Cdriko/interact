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

/**
 * Twitter feed manager.
 * <p>The TwitterFeeder allows to load and update one or multiple twitter feeds
 * by adding util functions to the basic Feeder class.</p>
 * 
 * @author Bruno Nadeau
 */
public class TwitterFeeder extends Feeder {

	private static final String SEARCH_URL = "http://search.twitter.com/search.atom?";
	
	private String ands = "";
	private String phrase = "";
	private String ors = "";
	private String nots = "";
	private String tag = "";
	private String lang = "all"; //all languages (default)
	
	private String from = "";
	private String to = "";
	private String ref = "";
	
	private String near = "";
	private int within = 15;
	private String units = "mi";
	
	private String since = "";
	private String until = "";
	
	private boolean positive = false;  // tude[]=:)
	private boolean negative = false; // tude[]=:(
	private boolean question = false; // tude[]=?
	private boolean links = false; // filter=links
	
	private int rpp = 15;
	private int page = 1;
	
	
	/**
	 * Create an empty Feeder.
	 */
	public TwitterFeeder() {
		super();
	}
	
	/**
	 * Search twitter using the specified query.
	 * @param query search query
	 */
	public void search(String query) {
		load(SEARCH_URL + "q=" + query.replace(' ', '+'));
	}
	
	/**
	 * Search twitter using the pre-specified search values.
	 */
	public void search() {
		//search and load tweets
		String query = "q=";
		query += "&ands=" + ands.replace(' ', '+');
		query += "&phrase=" + phrase.replace(' ', '+');
		query += "&ors=" + ors.replace(' ', '+');
		query += "&nots=" + nots.replace(' ', '+');
		query += "&lang=" + lang;
		query += "&from=" + from.replace(' ', '+');
		query += "&to=" + to.replace(' ', '+');
		query += "&ref=" + ref.replace(' ', '+');
		query += "&near=" + near.replace(' ', '+');
		query += "&within=" + within;
		query += "&units=" + units;
		query += "&since=" + since;
		query += "&until=" + until;
		query += "&tag=" + tag.replace(' ', '+');
		if (links) query += "&filter=links";
		if (positive) query += "&tude[]=%3A)";
		if (negative) query += "&tude[]=%3A(";
		if (question) query += "&tude[]=%3F";
		query += "&rpp=" + rpp;
		if (page > 1) query += "&page=" + page;
		
		//load the search
		load(SEARCH_URL + query);
	}
	
	/**
	 * Set the words that must be in a tweet.
	 * @param words words
	 */
	public void all(String words) {
		this.ands = words;
	}
	
	/**
	 * Set a phrase that should be in a tweet.
	 * @param phrase phrase
	 */
	public void phrase(String phrase) {
		this.phrase = phrase;
	}
	
	/**
	 * Set the words that can be in a tweet.
	 * @param words words
	 */
	public void any(String words) {
		this.ors = words;
	}
	
	/**
	 * Set the words that should not be in a tweet. 
	 * @param words words
	 */
	public void not(String words) {
		this.nots = words;
	}
	
	/**
	 * Set the hashtag that should be in a tweet.
	 * @param tag hashtag
	 */
	public void tag(String tag) {
		this.tag = tag;
	}
	
	/**
	 * Set the language a tweet should be in.
	 * @param lang language id (e.g. all, en, fr, etc)
	 */
	public void lang(String lang) {
		this.lang = lang;
	}
	
	/**
	 * Set the user a tweet should be from.
	 * @param user user
	 */
	public void from(String user) {
		this.from = user;
	}

	/**
	 * Set the user a tweet should be to.
	 * @param user user
	 */
	public void to(String user) {
		this.to = user;
	}
	
	/**
	 * Set the user a tweet should reference.
	 * @param user user
	 */
	public void ref(String user) {
		this.ref = user;
	}
	
	/**
	 * Set the place a tweet should be sent near from.
	 * @param place place
	 */
	public void near(String place) {
		this.near = place;
	}
	
	/**
	 * Set the within distance a tweet should be from a pre-specified place.
	 * @param dist distance
	 */
	public void within(int dist) {
		this.within = dist;
	}
	
	/**
	 * Set the type of unit used to measure the distance from a tweet's location.
	 * @param units km or mi
	 */
	public void unit(String units) {
		if (!units.equals("km") && !units.equals("mi")) {
			err("Unit of measure must be 'mi' or 'km'.");
			return;
		}
		
		this.units = units;
	}
	
	/**
	 * Set the unit of measurement to kilometers.
	 */
	public void km() {
		unit("km");
	}
	
	/**
	 * Set the unit of measurement to miles.
	 */
	public void mi() {
		unit("mi");
	}
	
	/**
	 * Set the date a tweet should have been posted after.
	 * @param date date (yyyy-mm-dd)
	 */
	public void since(String date) {
		this.since = date;
	}
	
	/**
	 * Set the date a tweet should have been posted before.
	 * @param date date (yyyy-mm-dd)
	 */
	public void until(String date) {
		this.until = date;
	}
	
	/**
	 * Set if a tweet must have received a positive :) attitude.
	 * @param positive true for a positive attitude, not to turn it off
	 */
	public void positive(boolean positive) {
		this.positive = positive;
	}

	/**
	 * Set if a tweet must have received a negative :( attitude.
	 * @param negative true for a negative attitude, not to turn it off
	 */
	public void negative(boolean negative) {
		this.negative = negative;
	}

	/**
	 * Set if a tweet must be a question.
	 * @param question true for a question, not to turn it off
	 */
	public void question(boolean question) {
		this.question = question;
	}
	
	/**
	 * Set if a tweet must contain links.
	 * @param links true if it contains links, false to turn it off
	 */
	public void links(boolean links) {
		this.links = links;
	}
	
	/**
	 * Set the number of returned tweets per search.
	 * @param rpp returned tweets per search
	 */
	public void rpp(int rpp) {
		if (rpp <= 0) {
			err("Returns per page must be greater than zero.");
			return;
		}
		
		this.rpp = rpp;
	}
	
	/**
	 * Set the page number that the search should return.
	 * @param page page number
	 */
	public void page(int page) {
		if (page <= 0) {
			err("Page must be greater than zero.");
			return;
		}
		
		this.page = page;
	}
}
