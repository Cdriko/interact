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

import com.sun.syndication.feed.synd.*;

/**
 * Entry callback interface.
 * 
 * <p>Interface used to catch entry-related events thrown by the feed manager.</p>
 * 
 * @author Bruno Nadeau
 */
public interface EntryCallback {
	/**
	 * Called when an event occur.
	 * @param entry
	 * @param feed
	 */
	public void event(SyndEntry entry, SyndFeed feed);
}