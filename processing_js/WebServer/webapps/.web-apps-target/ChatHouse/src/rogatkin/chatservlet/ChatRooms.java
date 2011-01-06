/* $RCSfile: ChatRooms.java,v $
 * Copyright (C) 2001 Dmitriy Rogatkin.  All rights reserved.
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
 *
 *  $Log: ChatRooms.java,v $
 *  Revision 1.2  2001/01/09 23:16:30  dmitriy
 *  added more properties
 *  copyright year corrected
 *
 *  Revision 1.1  2001/01/09 22:56:36  dmitriy
 *  getting rid of singleton like chat rooms
 *   implementing of notification
 *
 */

package rogatkin.chatservlet;
import java.util.*;
public final class ChatRooms extends HashMap {
	public final static String PROP_ROOMLIST = "ROOMLIST";
	final static String HV_LOCK = "lock";
	final static String HV_SIZE = "size";
	final static String HV_ROOM = "room_name";

	private Properties properties;
	private NotificationEngine notificationEngine;
	
	ChatRooms(Properties _properties, NotificationEngine _notificationEngine) {
		String rl = _properties.getProperty(PROP_ROOMLIST);
		if (rl != null) {
			StringTokenizer rt = new StringTokenizer(rl, ";");
			while(rt.hasMoreTokens()) {
				String rn = rt.nextToken();
				String en = null;
				int cp = rn.indexOf(':');
				if (cp > 0) {
					en = rn.substring(cp+1);
					rn = rn.substring(0, cp);
				}
				if (get(rn) == null)
					put(rn, new ChatRoom(en, true, this));
			}
		}
		properties = _properties;
		notificationEngine = _notificationEngine; 
	}

    public ArrayList buildRoomList() {
        return buildRoomList(false);
    }
    
    public ArrayList buildRoomList(boolean _visitors) {
        // filling rooms
        ArrayList roomList = new ArrayList();
        Iterator i = keySet().iterator();
        while(i.hasNext()) {
            HashMap item = new HashMap();
            item.put(HV_ROOM, i.next());
            if (_visitors) {
                ChatRoom cr = (ChatRoom)get(item.get(HV_ROOM));
                item.put(HV_LOCK, cr.isLocked()?item:null);
                // must be not null
                item.put(HV_SIZE, Integer.toString(cr.getRoomListenerCount()));
                item.put(Entrance.HV_USER, cr.getRoomListenerName());
            }
            roomList.add(item);
        }
        return roomList;
    }
	// below methos used to avoid direct servlet acces, just to make this code
	// working beside servlets
	Properties getProperties() {
		return properties;
	}
	
	NotificationEngine getNotificationEngine() {
		return notificationEngine;
	}
}
