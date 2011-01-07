/* $RCSfile: Notification.java,v $
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
 *  $Log: Notification.java,v $
 *  Revision 1.10  2005/08/25 00:38:12  rogatkin
 *  using maps
 *
 *  Revision 1.9  2001/01/11 23:34:32  dmitriy
 *  fixed HTML forms
 *  keeping private conversation after setting up a notification
 *  authorization fix
 *
 *  Revision 1.8  2001/01/11 10:21:59  dmitriy
 *  invite notification implementation
 *
 *  Revision 1.7  2001/01/10 04:03:17  dmitriy
 *  added getting rid of notification
 *  minor HTML adjustment
 *
 *  Revision 1.6  2001/01/09 23:33:05  dmitriy
 *  avoiding to send message to youself
 *
 *  Revision 1.5  2001/01/09 23:16:30  dmitriy
 *  added more properties
 *  copyright year corrected
 *
 *  Revision 1.4  2001/01/09 22:56:36  dmitriy
 *  getting rid of singleton like chat rooms
 *   implementing of notification
 *
 *  Revision 1.3  2001/01/09 04:39:27  dmitriy
 *  dummy instant mail notification
 *
 *  Revision 1.2  2001/01/08 10:09:01  dmitriy
 *  CVS tag correction
 *
 *  Revision 1.1  2001/01/08 10:02:00  dmitriy
 *  work on notification mechanism
 *  and direct messages
 *
 */

package rogatkin.chatservlet;
import java.util.*;
import java.io.*;
import rogatkin.servlet.*;

public class Notification  extends BaseFormProcessor {
	final static String PP_EMAIL = "email";
	final static String PP_NAME = "name";
	final static String PP_CONDITION = "condition";

	public static final String UNKNOWN = "Unknown";
	public static final String COND_JOIN = "joins";
	public static final String COND_LEFT = "leaves";
	public static final String COND_RIDOF = "ridof";
	public static final String COND_INVITE = "invites";

	protected Map producePageData() {
		HashMap result = (HashMap)getSessionData();
		result.put(Entrance.HV_ROOM_SEL, ((ChatServlet)dispatcher).getChatRooms().buildRoomList(true));
		result.put(Input.HV_USER, getStringParameterValue(Input.PP_SENDTO, "", 0));
		result.put(Entrance.HV_USER, result.get(Input.HV_USER));
		return result;
	}
	
	protected Map validateFormData() {
		String mailTo = getStringParameterValue(PP_EMAIL, "", 0);
		if (mailTo.length() > 0)
			((ChatServlet)dispatcher).getNotificationEngine().add(new Object[] {mailTo,
																  getStringParameterValue(PP_NAME, UNKNOWN, 0),
																  getStringParameterValue(Entrance.HV_ROOM_SEL, UNKNOWN, 0),
																  getStringParameterValue(PP_CONDITION, COND_JOIN, 0),
																  getSession().getAttribute(USER_NAME).toString()});
		return null;
	}

	protected String getCharSet() {
		try {
			return ((ChatRoom) getSession().getAttribute(getSession().getAttribute(USER_NAME).toString())).getEncoding();
		} catch(NullPointerException npe) {
		}
		return null;
	}
	
	protected String getTemplateName() {
		return "notification.htm";
	}
	
	protected String getSubmitPage() {
		return "Input?sendto="+getStringParameterValue(Input.PP_SENDTO, "", 0);
	}
	
	protected String getCancelPage() {
		return getSubmitPage();
	}
	
	protected String getExpiredPage() {
		return "Entrance"; // _top target
	}
}