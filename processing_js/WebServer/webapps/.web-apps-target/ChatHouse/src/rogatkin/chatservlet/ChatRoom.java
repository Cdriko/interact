/* $RCSfile: ChatRoom.java,v $
 * Copyright (C) 2000, 2001 Dmitriy Rogatkin.  All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
 *  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 *  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 *  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *  $Log: ChatRoom.java,v $
 *  Revision 1.22  2001/01/23 04:19:52  dmitriy
 *  be populated outside of inner hashmap
 *
 *  Revision 1.21  2001/01/09 23:16:30  dmitriy
 *  added more properties
 *  copyright year corrected
 *
 *  Revision 1.20  2001/01/09 22:56:36  dmitriy
 *  getting rid of singleton like chat rooms
 *   implementing of notification
 *
 *  Revision 1.19  2001/01/09 04:39:27  dmitriy
 *  dummy instant mail notification
 *
 *  Revision 1.18  2001/01/08 10:09:00  dmitriy
 *  CVS tag correction
 *
 *  Revision 1.17  2001/01/08 10:02:00  dmitriy
 *  work on notification mechanism
 *  and direct messages
 *
 */
 
/** @author <A HREF="mailto:dmitriy@mochamail.com">Dmitriy Rogatkin</A>
 */
package rogatkin.chatservlet;
import java.util.*;
import javax.swing.event.EventListenerList;
import javax.servlet.http.HttpSessionBindingListener;
import javax.servlet.http.HttpSessionBindingEvent;
import rogatkin.servlet.BaseFormProcessor;
import rogatkin.servlet.Dispatcher;
public class ChatRoom extends ArrayList implements RoomListener, HttpSessionBindingListener { 
    public static final String SYSTEM_ORIG = "System";
	public static final String PROP_HISTORYDEPTH = "HISTORYDEPTH";
	public static final String PROP_REMOVEDEPTH = "REMOVEDEPTH";
	public static final String PROP_DESTROYEMPTYTEMPROOMS = "DESTROYEMPTYTEMPROOMS";
	public static final int DEFAUL_MAX_LISTENERS = 10;
	public static final String USENCODING = "US-ASCII";
	public static final String VAL_YES = "yes";
	int maxListeners = DEFAUL_MAX_LISTENERS;
	private String encoding;
	private boolean locked;
	// permanent room can't be removed from a house
	private boolean permanent;
	private ChatRooms house;
	
	
	ChatRoom(ChatRooms _house) {
		this(USENCODING, false, _house);
	}
	
	ChatRoom(String _encoding, boolean _permanent, ChatRooms _house) {
		encoding = _encoding;
		if (encoding == null)
			encoding = USENCODING;
		permanent = _permanent;
		house = _house;
	}
	
	public void addRoomListener(RoomListener  _roomListener) throws java.util.TooManyListenersException {
		if (listenersList.getListenerCount() > maxListeners)
			throw new TooManyListenersException("Number listeners for "+getName()+" exceeded "+maxListeners);
		// remove first if we already have it
		listenersList.remove(RoomListener.class, lookUpRoomListener(_roomListener.getName()));
		listenersList.add(RoomListener.class, _roomListener);
	}

	public void removeRoomListener(RoomListener  _roomListener) {
		// race condition isn't resolved here clearly
		synchronized (listenersList) {
			listenersList.remove(RoomListener.class, _roomListener);
			// if the room is empty it can be removed from a house
			if (listenersList.getListenerCount(RoomListener.class) <= 0) {
				if(!isPermanent() && VAL_YES.equalsIgnoreCase(house.getProperties().getProperty(PROP_DESTROYEMPTYTEMPROOMS))) {
					synchronized(house) {
						house.remove(getName());
					}
				}
				if (isLocked()) {
					clear();
					setLock(false);
				}
			}
		}
	}

	public void removeRoomListener(String  _listenerName) {
		removeRoomListener(lookUpRoomListener(_listenerName));
	}
	
	public RoomListener lookUpRoomListener(String  _listenerName) {
		synchronized(listenersList) {
			EventListener[] el = listenersList.getListeners(RoomListener.class);
			for (int i=0; i<el.length; i++) 
				if(((RoomListener)el[i]).getName().equals(_listenerName))
					return (RoomListener)el[i];
		}
		return null;
	}
	
	public int getRoomListenerCount() {
		return listenersList.getListenerCount();
	}
	
	public synchronized void addMessage(Object[] _msg) {
		add(_msg);
		try {
			if (size() > Integer.parseInt(house.getProperties().getProperty(PROP_HISTORYDEPTH)))
				removeRange(0, Integer.parseInt(house.getProperties().getProperty(PROP_REMOVEDEPTH)));
		} catch(Exception e) { // number format, null pointer
		}
		// notify listener
		EventListener[] el = listenersList.getListeners(RoomListener.class);
		for (int i=0; i<el.length; i++) {
			if (_msg.length < 5 || _msg[4] == null || _msg[4].toString().length() == 0
				|| ((RoomListener)el[i]).getName().equals(_msg[4])
				|| ((RoomListener)el[i]).getName().equals(_msg[0]))
				((RoomListener)el[i]).addMessage(_msg);
		}
	}
	
	public String getName() {
		Iterator i = house.keySet().iterator();
		while(i.hasNext()) {
			Object n = i.next();
			if (house.get(n) == this)
				return n.toString();
		}
		return null;
	}
	
	public String getEncoding() {
		return encoding;
	}
	
	public synchronized void setLock(boolean _on) {
		locked = _on;
	}
	
	public synchronized boolean isLocked() {
		return locked;
	}
	
	public boolean isPermanent() {
		return permanent;
	}
	
	public String[] getRoomListenerName() {
		EventListener[] el = listenersList.getListeners(RoomListener.class);
		String result[] = new String[el.length];
		for (int i=0; i<el.length; i++)
			result[i] = ((RoomListener)el[i]).getName();
		return result;
	}
	
	// TODO: make notification asychronous
	public void valueBound(HttpSessionBindingEvent event) {
		String eam = event.getName();
		addMessage(new Object[] {SYSTEM_ORIG,
				   "<b>"+eam+"</b> has joined the room ["+getName(),
				   "green"});
		house.getNotificationEngine().process(eam, getName(), true);
	}

	public void valueUnbound(HttpSessionBindingEvent event) {
		String eam = event.getName();
		addMessage(new Object[] {SYSTEM_ORIG,
				   "<b>"+eam +"</b> has left the room ["+getName(),
				   "green"});
		// remove as a listener for this room
		removeRoomListener(eam);
		Object monitor = event.getSession();
		synchronized(monitor) {
			monitor.notify();
		}
		house.getNotificationEngine().process(eam, getName(), false);
	}

	private EventListenerList listenersList = new EventListenerList();
}
