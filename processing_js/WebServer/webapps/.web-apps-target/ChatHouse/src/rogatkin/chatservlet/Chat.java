/* $Id: Chat.java,v 1.17 2006/01/11 05:38:46 rogatkin Exp $
 * Copyright (C) 2000-2005 Dmitriy Rogatkin.  All rights reserved.
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
 */

package rogatkin.chatservlet;
import java.util.*;

import rogatkin.servlet.*;

public final class Chat extends BaseFormProcessor {
	public static final String PRODUCT_NAME = "Chat House";
	public static final String PRODUCT_VERSION = "1.0";
	public static final String PRODUCT_COPYRIGHT = "Dmitriy Rogatkin 2000-2006";
	
	final static String PP_ROOM = "room";	
	protected Map producePageData() {
		String room = getStringParameterValue(PP_ROOM, "", 0);
		if (room.length() > 0 )  {
			ChatRoom newRoom = (ChatRoom)((ChatServlet)dispatcher).getChatRooms().get(room);
			if (newRoom != null && !newRoom.isLocked()				&& newRoom.equals(getSession().getAttribute(getSession().getAttribute(USER_NAME).toString())) == false)
				getSession().setAttribute(getSession().getAttribute(USER_NAME).toString(), newRoom);
		}
		return (HashMap)getSessionData();
	}
	
	protected Map validateFormData() {
		return null;
	}
	
	protected String getTemplateName() {
		return "chat_page.htm";
	}
	
	protected String getSubmitPage() {
		return null;
	}
	
	protected String getCancelPage() {
		return null;
	}
	
	protected String getExpiredPage() {
		return "Entrance";
	}
}
