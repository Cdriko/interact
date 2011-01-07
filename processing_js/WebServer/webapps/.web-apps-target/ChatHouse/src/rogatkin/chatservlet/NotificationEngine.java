/* $RCSfile: NotificationEngine.java,v $
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
 *  $Log: NotificationEngine.java,v $
 *  Revision 1.8  2004/06/04 08:05:47  rogatkin
 *  work on serialization
 *
 *  Revision 1.7  2001/08/03 08:06:44  rogatkin
 *  formatting
 *
 *  Revision 1.6  2001/01/23 04:19:52  dmitriy
 *  be populated outside of inner hashmap
 *
 *  Revision 1.5  2001/01/11 10:21:59  dmitriy
 *  invite notification implementation
 *
 *  Revision 1.4  2001/01/10 04:03:17  dmitriy
 *  added getting rid of notification
 *  minor HTML adjustment
 *
 *  Revision 1.3  2001/01/09 23:33:05  dmitriy
 *  avoiding to send message to youself
 *
 *  Revision 1.2  2001/01/09 23:16:30  dmitriy
 *  added more properties
 *  copyright year corrected
 *
 *  Revision 1.1  2001/01/09 22:56:36  dmitriy
 *  getting rid of singleton like chat rooms
 *   implementing of notification
 *
 *
 */
package rogatkin.chatservlet;
import java.util.*;
import java.text.*;
import java.io.*;
import rogatkin.*;

public final class NotificationEngine extends ArrayList { 
	public final static String PROP_CHATHOUSE_MAIL = "CHATHOUSE_MAIL";
	public final static String PROP_MAIL_SUBJECT = "MAIL_SUBJECT";
	public final static String PROP_MAIL_BODY = "MAIL_BODY";
	public final static String PROP_INVITE_TEXT = "INVITE_TEXT";
	
	public static final String ANY_ROOM = "Any";

    /** Notification event looks like:
     * [0] - mailTo
     * [1] - a participant
     * [2] - a room
     * [3] - an action (joined, left, notified, rid of)
     * [4] - an originator
     */
	private transient SendMail sendMail;
	private Properties properties;
	private transient ChatServlet chatServlet;
		
	NotificationEngine(Properties _properties, ChatServlet _chatServlet) {
		sendMail = new SendMail(_properties);
		properties = _properties;
		chatServlet = _chatServlet;
	}
	
	// TODO: avoid to sending a notification to yourself
	void process(String _participant, String _room, boolean _join) {
		synchronized(this) {
			for(int i=0; i<size(); i++) {
				Object [] event = (Object[])get(i);
				if (!event[4].toString().equals(_participant)
					&& (_join && Notification.COND_JOIN.equals(event[3])
					|| !_join && Notification.COND_LEFT.equals(event[3]))) {
					if ((event[1].equals("*") || event[1].toString().length() == 0 ||
						event[1].equals(_participant)) && (event[2].equals(ANY_ROOM)
						|| event[2].toString().length() == 0 ||
						event[2].equals(_room)))
						sendMail(new Object[] {event[0], _participant, _room, event[3]}) ;
					// put i in removing list and remove then
				}
			}
		}
	}
	
	public boolean add(Object _o) {
		synchronized(this) {
			Object[] event = (Object[]) _o;
			if (Notification.COND_RIDOF.equals(event[3])) {
				for(int i=size()-1; i>=0; i--)
					if (((Object[])get(i))[0].equals(event[0]))
						remove(i);
				return true;
			} else if (Notification.COND_INVITE.equals(event[3])) {
				sendMail(new Object[] {event[0], event[4], event[2],
						 properties.getProperty(PROP_INVITE_TEXT, "invites to")}) ;
				return true;
			}
			return super.add(_o);
		}
	}
		
	private void sendMail(Object []_event) {
		try {
			sendMail.send(properties.getProperty(PROP_CHATHOUSE_MAIL, Chat.PRODUCT_NAME)
						  , _event[0].toString()
							, MessageFormat.format(properties.getProperty(PROP_MAIL_SUBJECT, "Chat House Notification"), _event)
							  , MessageFormat.format(properties.getProperty(PROP_MAIL_BODY,
																			"The person {1} {3} the room {2}."), _event)
								, null); // TODO: add content type and encoding
		} catch(IOException ioe) {
			chatServlet.log("Exception happened at an attempt to send e-mail ["+ioe);
		}
	}							   
}
