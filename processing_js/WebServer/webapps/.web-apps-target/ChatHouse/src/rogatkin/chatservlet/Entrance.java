/* $RCSfile: Entrance.java,v $
 * Copyright (C) 2000 Dmitriy Rogatkin.  All rights reserved.
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
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *  $Log: Entrance.java,v $
 *  Revision 1.20  2005/08/25 00:38:12  rogatkin
 *  using maps
 *
 *  Revision 1.19  2002/01/10 03:16:04  rogatkin
 *  copyright update and other minor changes
 *
 *  Revision 1.18  2001/05/10 19:46:53  dmitriy
 *  spelling
 *
 *  Revision 1.17  2001/01/11 10:01:01  dmitriy
 *  first implementation of message board in full
 *
 *  Revision 1.16  2001/01/09 22:56:36  dmitriy
 *  getting rid of singleton like chat rooms
 *   implementing of notification
 *
 *  Revision 1.15  2001/01/09 04:39:27  dmitriy
 *  dummy instant mail notification
 *
 *  Revision 1.14  2001/01/08 10:09:00  dmitriy
 *  CVS tag correction
 *
 */

package rogatkin.chatservlet;
import java.util.*;
import javax.servlet.http.HttpSession;

import rogatkin.servlet.*;
// TOTO: a potential problem in scurity of private messages
// if some other user entered in the chat with the name of
// previous left user
public class Entrance extends BaseFormProcessor {
	public static final String PROP_MAXROOMS = "MAXROOMS";
	public static final int DEFAULT_MAX_ROOMS = 1000;
	public static final String VAL_CREATE = "Create:";
	public static final String PROP_TEMPROOMCHARSET = "TEMPROOMCHARSET";
	
	final static String HV_ROOM_SEL = "room_sel";
	final static String HV_DIAGNOSTIC = "diagnostic";
	final static String HV_USER = ".user";
	
	protected Map producePageData() {
		HashMap result = (HashMap)getSessionData();
		result.put(HV_ROOM_SEL, ((ChatServlet)dispatcher).getChatRooms().buildRoomList(true));
		result.put(Manageboard.HV_MESSAGE, ((ChatServlet)dispatcher).getMessageBoard().getBoard());
                resp.addCookie(new javax.servlet.http.Cookie("My_cookies_", "Some_funny%20variable"));
		return result;
	}

	protected boolean isLoginForm() {
		return true;
	}
	
	protected Map validateFormData() {
		HashMap result = (HashMap)getSessionData();
		result.put(HV_DIAGNOSTIC, null);
		// TODO: use resources for messages
		String s = getStringParameterValue(HV_USER, "", 0);
		if (s.length() == 0)
			result.put(HV_DIAGNOSTIC, "Please, provide your name");
		else
			result.put(HV_USER, rogatkin.HttpUtils.htmlEncode(s));
		ArrayList roomsList = ((ChatServlet)dispatcher).getChatRooms().buildRoomList(true);
		// check uniqueness name across the rooms
		// Note: since no synchronization here, race condition will be here
		// Please add synchronization by rooms here in production version
		for (int i=0; i<roomsList.size(); i++) {
			String [] visitors = (String[])((HashMap)roomsList.get(i)).get(HV_USER);
			for (int j=0; j<visitors.length; j++)
				if (visitors[j].equals(s)) {
					result.put(HV_DIAGNOSTIC, "There's a user with the same name in the house");
					break;
				}
		}
		s = getStringParameterValue(HV_ROOM_SEL, "", 0);
		result.put(HV_ROOM_SEL, roomsList);
		if (s.length() != 0)
			for (int i=0; i<roomsList.size(); i++) {
				HashMap hm = (HashMap)roomsList.get(i);
				if (s.equals(hm.get(ChatRooms.HV_ROOM)))
					hm.put(HTML_SELECTED, HTML_SELECTED);
			}
		else
			result.put(HV_DIAGNOSTIC, "You have to select a room, or create a new one");
		if (s.equals(VAL_CREATE)) {
			s = getStringParameterValue(ChatRooms.HV_ROOM, "", 0);
			if (s.length() == 0)
				result.put(HV_DIAGNOSTIC, "Please specify a name of a created room");
			else
				result.put(ChatRooms.HV_ROOM, s);
		}
		if (result.get(HV_DIAGNOSTIC) == null) {
			ChatRooms rooms = ((ChatServlet)dispatcher).getChatRooms();
			Object room;
			if ((room = rooms.get(s)) == null)
				synchronized(rooms) { // we could remove it in case of global synchronization
					if ((room = rooms.get(s)) == null) {
						int maxRooms = DEFAULT_MAX_ROOMS;
						try {
							maxRooms = Integer.parseInt(dispatcher.getProperty(PROP_MAXROOMS));
						} catch(Exception e) { // null pointer, number format
						}
						if (rooms.size() < maxRooms)
							rooms.put(s, room = new ChatRoom(dispatcher.getProperty(PROP_TEMPROOMCHARSET), false, rooms));
						else {
							result.put(HV_DIAGNOSTIC, "Too many rooms, try using existing one");
							return result;
						}
					}
				}
			if (((ChatRoom)room).isLocked()) {
				result.put(HV_DIAGNOSTIC, "This room is locked, try another one");
				return result;
			}
			HttpSession session = getSession();
			session.setAttribute(USER_NAME, result.get(HV_USER));
			session.setAttribute(session.getAttribute(USER_NAME).toString(), room);
			setLogged(true);
			return null;
		}
		return result;
	}
		
	protected String getTemplateName() {
		return "entry_page_to_chat.htm";
	}
	
	protected String getSubmitPage() {
		return "Chat";
	}
	
	protected String getCancelPage() {
		return null;
	}
	
	protected String getExpiredPage() {
		return "Entrance";
	}
	
	protected String getCharSet() {
		return "UTF-8";
	}
}