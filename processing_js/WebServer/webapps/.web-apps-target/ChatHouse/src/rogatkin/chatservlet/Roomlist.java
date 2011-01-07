/* $RCSfile: Roomlist.java,v $
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
 *  $Log: Roomlist.java,v $
 *  Revision 1.25  2006/11/15 20:18:45  rogatkin
 *  skip res req
 *
 *  Revision 1.24  2006/01/09 08:05:53  rogatkin
 *  added tooltip
 *
 *  Revision 1.23  2005/12/07 05:42:52  rogatkin
 *  tree trav interface extended
 *
 *  Revision 1.22  2005/10/31 05:32:28  rogatkin
 *  url encoding form jdk
 *
 *  Revision 1.21  2005/08/25 00:38:12  rogatkin
 *  using maps
 *
 *  Revision 1.20  2003/02/18 06:21:15  rogatkin
 *  html encoding for url like substrings
 *
 *  Revision 1.19  2001/01/23 22:11:37  dmitriy
 *  replaced URL encode by home made one
 *
 *  Revision 1.18  2001/01/23 04:19:52  dmitriy
 *  be populated outside of inner hashmap
 *
 *  Revision 1.17  2001/01/23 00:32:56  dmitriy
 *  correct charset en/decoding of URL variables
 *
 *  Revision 1.16  2001/01/09 22:56:36  dmitriy
 *  getting rid of singleton like chat rooms
 *   implementing of notification
 *
 *  Revision 1.15  2001/01/08 10:09:01  dmitriy
 *  CVS tag correction
 *
 *  Revision 1.14  2001/01/08 10:02:00  dmitriy
 *  work on notification mechanism
 *  and direct messages
 *
 */
package rogatkin.chatservlet;
import java.util.*;
import java.net.URLEncoder;
import java.io.UnsupportedEncodingException;

import rogatkin.servlet.*;
public class Roomlist extends BaseFormProcessor implements Traversable {
	final static String HV_ROOMS = "rooms";

	static TreeViewHelper viewHelper = new TreeViewHelper("rooms");

	protected Map producePageData() {
		HashMap result = (HashMap)getSessionData();
		viewHelper.apply(result, this, this, "", null);
		result.put(Input.HV_ENCODING, getCharSet());
		
		return result;
	}
	
	protected Map validateFormData() {
		return null;
	}
	
	protected String getTemplateName() {
		return "rooms_page.htm";
	}
	
	protected String getSubmitPage() {
		return null;
	}
	
	protected String getCancelPage() {
		return null;
	}
	
	protected String getExpiredPage() {
		return "Entrance"; // _top target
	}
	
	protected String getCharSet() {
		try {
			return ((ChatRoom) getSession().getAttribute(getSession().getAttribute(USER_NAME).toString())).getEncoding();
		} catch(NullPointerException npe) {
		}
		return null;
	}
	
// -- 
	public List getChildren(Object _parent) {
		ArrayList result = new ArrayList();
		if (_parent == null) {
			ChatRooms rooms = ((ChatServlet)dispatcher).getChatRooms();
			Iterator i = rooms.keySet().iterator();
			while(i.hasNext()) 
				result.add(rooms.get(i.next()));
		} else if (_parent instanceof ChatRoom) {
			String[] rls = ((ChatRoom)_parent).getRoomListenerName();
			for (int i=0; i<rls.length; i++)
				result.add(rls[i]);
		}

		return result;
	}
	
	public String getName(Object _object) {
		if (_object instanceof ChatRoom)
			return ((ChatRoom)_object).getName();
		else if (_object == null)
			return "Chat House";
		return rogatkin.HttpUtils.htmlDecode(_object.toString());
	}
	
	public String getId(Object _object) {
		return getName(_object);
	}
	
	public String getHref(Object _object) {
		try {
			if (_object == null || _object instanceof ChatRoom)
				return "Chat?room="+URLEncoder.encode(getName(_object), getCharSet())
					+"\" target=\"_top";
			return "Input?sendto="+URLEncoder.encode(_object.toString(), getCharSet())
				+"\" target=\"UserInput";
		}catch(UnsupportedEncodingException ue) {
			return ""+ue;
		}
	}
	
	public String getPage(Object _object) {
		return "Roomlist";
	}

	public boolean canMark(Object _object, boolean _opened) {
		return _object != null && (_object instanceof ChatRoom == false);
	}

	public String getImageModifier(Object _object) {
		if (_object instanceof ChatRoom) {
			ChatRoom cr =(ChatRoom)_object;
			if (cr.isLocked())
				return "Image/lock";
			else if (cr.getRoomListenerCount() == 0)
				return "folder";
			return "Treeimage/space";
		}
		if (_object == null)
			return "Treeimage/space";
		return "site_user";
	}
	
	public boolean isTheObject(Object _object, String _object2) {
		return _object2.equals(getId(_object));
	}

	public String getToolTip(java.lang.Object _o) {
               if (_o instanceof ChatRoom) 
			return _o.toString();
		return null;
	}

	protected boolean useLabels() {
		return false;
	}
}
