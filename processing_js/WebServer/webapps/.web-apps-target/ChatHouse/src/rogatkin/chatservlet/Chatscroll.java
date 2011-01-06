/* $RCSfile: Chatscroll.java,v $
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
 *
 *  $Log: Chatscroll.java,v $
 *  Revision 1.25  2004/08/04 04:43:40  rogatkin
 *  touched`
 *
 *  Revision 1.24  2004/06/04 08:05:47  rogatkin
 *  work on serialization
 *
 *  Revision 1.23  2002/04/13 08:24:48  rogatkin
 *  null ptr fix
 *
 *  Revision 1.22  2001/01/13 01:23:48  dmitriy
 *  using max upload size
 *  some experimenting with uploading large files
 *
 *  Revision 1.21  2001/01/10 04:03:17  dmitriy
 *  added getting rid of notification
 *  minor HTML adjustment
 *
 *
 */
package rogatkin.chatservlet;
import java.util.*;
import java.io.*;
import java.text.MessageFormat;

import javax.servlet.http.*;
import javax.servlet.*;

import rogatkin.servlet.*;
public final class Chatscroll implements PageServant, Serializable {
	public final static String PROP_CHATLOGHEADER = "CHATLOGHEADER";
	public final static String PROP_MESSAGELINE = "MESSAGELINE";
	public final static String PROP_BODYTAG = "BODYTAG";
	public int SCROLL_SIZE = 20;
	final static String MULTIPARTMIXED = "multipart/x-mixed-replace; boundary=";
	final static String SEP = "--";
	final static String CONTENTTYPE_HDR = "Content-type: text/html; charset=";
	final static String DEF_MSG_LINE =
		"<font color={2}><b>[{0}]</b>&nbsp;&nbsp;</font><i>{1}</i><br>";
	
	public void serve(final HttpServletRequest _req,
							HttpServletResponse _resp,
							final Dispatcher _dispatcher)
		throws IOException, ServletException {
		final String boundary = genBoundary();
		_resp.setContentType(MULTIPARTMIXED+boundary);
		final ServletOutputStream out = _resp.getOutputStream();
		try {
			// TODO: check if logged in
			// do get previous log ?		
			final String user = _req.getSession().getAttribute(BaseFormProcessor.USER_NAME).toString();
			final ChatRoom cr = (ChatRoom) _req.getSession().getAttribute(user);
			String te =	cr.getEncoding();
			if (te == null)
				te = "UTF-8";
			final String encoding = te;
			if (!isIE(_req)) {
				out.println(SEP+boundary);
				out.println(CONTENTTYPE_HDR + encoding);
				out.println(); 
			}
			outHeader(out, encoding, true, _dispatcher);
			// it can be refresh, but transcript for a new participant it can be also
			// interesting
			rollPreviousMessages(out, cr, true, encoding, user, _dispatcher);
			if (!isIE(_req)) {
				outFooter(out);
				out.println();
				out.flush();
			}
			Object monitor = _req.getSession();
			synchronized(monitor) {
				monitor.notify();
			}
			try {
				// previous listener is removed automatically
				cr.addRoomListener(
								   new RoomListener() {
									   public void addMessage(Object[] _msg) {
										   try {
											   if (!isIE(_req)) {
												   out.println(SEP+boundary);
												   out.println(CONTENTTYPE_HDR + encoding);
												   out.println(); 
												   outHeader(out, encoding, true, _dispatcher);
												   rollPreviousMessages(out, cr, false, encoding, user, _dispatcher);
											   }
											   chatMessage(out, _msg, encoding, user, _dispatcher);
											   if (!isIE(_req)) {
												   outFooter(out);
												   out.println();
												   out.flush();
											   }
										   } catch ( IOException ioe) {
											   // just eat it
											   //Object monitor = _req.getSession();
											   //synchronized(monitor) {
												//   monitor.notify();
											   //}
										   }
									   }
						
									   public String getName() {
										   return user;
						}
				});
				synchronized(monitor) {
					try {
						monitor.wait();
					} catch(InterruptedException ie ) {					}
				}
			} catch(TooManyListenersException tmle) {
				outError(out, "The room over crowded.");
			}
			if (isIE(_req))
				outFooter(out);
			else
				out.println(SEP+boundary+SEP);
		} catch( NullPointerException npe) { // can happen if no session or room
		} catch( IOException ioe) {
			// just eat it
		} finally {
			if (out != null)
				out.close();
		}
	}
	
	protected void rollPreviousMessages(ServletOutputStream _out, ChatRoom _chatRoom
										, boolean _lastIncluded, String _encoding, String _name, Dispatcher _dispatcher) throws IOException {
		// roll something previous
		// notice, no synchronization here
		for (int i = _chatRoom.size()-SCROLL_SIZE >= 0?_chatRoom.size()-SCROLL_SIZE:0;
			 i < _chatRoom.size()-(_lastIncluded?0:1); i++) {
			chatMessage(_out, (Object[]) _chatRoom.get(i), _encoding, _name, _dispatcher);
		}											   
	}
		
	protected void outHeader(ServletOutputStream _out, String _encode, boolean refreshRequested, Dispatcher _dispatcher)  throws IOException {
		String logHeader = _dispatcher.getProperty(PROP_CHATLOGHEADER);
		String bodyTag = _dispatcher.getProperty(PROP_BODYTAG);
		if (bodyTag == null || bodyTag.length() == 0)
			bodyTag = "<body>";
		if (logHeader == null)
			logHeader = "<h2>Chat Log</h2>";
		_out.print("<html><HEAD><META http-equiv=\"Content-Type\" "
                  +"content=\"text/html; charset="+_encode+"\">");
		if (refreshRequested)
			_out.print("<META HTTP-EQUIV=\"Refresh\" CONTENT=\"180; URL=Chatscroll\">");
		_out.print("<TITLE>ChatHouse Chat Transcript</TITLE>");
		_out.print("<SCRIPT LANGUAGE=javascript>");
		_out.print("<!-- \n");
		_out.print("var ppop=null;\n");
		_out.print("var count = 0;\n");
		_out.print("function showPopup (location) {\n");
		_out.print("count = count+1;\n");
		_out.print("ppop = window.open (location,\n");
		_out.print("\"PrintWindow\"+count,\"scrollbars=yes,width=700,height=600,screenX=150,screenY=0,resizable=yes,status=yes\");\n");
		_out.print("if(navigator.userAgent.indexOf(\"MSIE 3\") == -1) {\n");
		_out.print("            ppop.focus();\n");
		_out.print("}\n");
		_out.print("window.onerror=null;\n");
		_out.print("}\n");
		_out.print("//-->\n");
		_out.print("</SCRIPT>");
		_out.print("</HEAD>");
		_out.print(bodyTag);
		_out.print(MessageFormat.format(logHeader, new Object[] {Chat.PRODUCT_NAME, Chat.PRODUCT_VERSION, Chat.PRODUCT_COPYRIGHT}));
		
	}

	protected void outFooter(ServletOutputStream _out) throws IOException {
		_out.print("</body></html>");
	}

	protected void outError(ServletOutputStream _out, String _error)  throws IOException {
		_out.print("<b>"+_error+"</b>");
	}
	
	protected void chatMessage(ServletOutputStream _out, Object[] _message, String _encoding, 
							   String _participantName, Dispatcher _dispatcher) throws IOException {
		String patternString = _dispatcher.getProperty(PROP_MESSAGELINE);
		if (_message.length < 5 || _message[4] == null 
			|| _message[4].toString().length() == 0 || _participantName.equals(_message[4])
			|| _participantName.equals(_message[0])) { 
			if (patternString == null)
				patternString = DEF_MSG_LINE;
			_out.write(MessageFormat.format(patternString, _message).getBytes(_encoding));
			_out.flush();
		}
	}

	private String genBoundary() {
		return Long.toHexString(new Random().nextLong());
	}

	public boolean isThreadSafe() {
		return true;
	}
	
	public boolean isThreadFriendly() {
		return true;
	}

	protected boolean isIE(HttpServletRequest _req) {
		try {
			String ua = _req.getHeader(BaseFormProcessor.USER_AGENT);
			return ua.indexOf("MSIE") > 0 || ua.indexOf("Netscape6") > 0;
		} catch(NullPointerException npe) {
			return false;
		}
	}		   

}
