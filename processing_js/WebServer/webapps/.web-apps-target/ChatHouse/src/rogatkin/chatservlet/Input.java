/* $RCSfile: Input.java,v $
 * Copyright (C) 2000-2003 Dmitriy Rogatkin.  All rights reserved.
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
 *  $Log: Input.java,v $
 *  Revision 1.28  2006/06/17 05:35:22  rogatkin
 *  url recognitions with digits in protocol
 *
 *  Revision 1.27  2006/06/15 05:17:33  rogatkin
 *  fix looping in some url recognition
 *
 *  Revision 1.26  2006/04/15 21:44:03  rogatkin
 *  removed unused
 *
 *  Revision 1.25  2006/01/11 05:38:46  rogatkin
 *  tuned for the latest distro and demrog
 *
 *  Revision 1.24  2005/08/25 00:38:12  rogatkin
 *  using maps
 *
 *  Revision 1.23  2003/02/18 06:21:15  rogatkin
 *  html encoding for url like substrings
 *
 *  Revision 1.22  2002/02/27 10:07:13  rogatkin
 *  added calling URL highlight
 *
 *  Revision 1.21  2001/02/01 08:14:37  dmitriy
 *  new message board impl
 *
 *  Revision 1.20  2001/01/13 01:23:48  dmitriy
 *  using max upload size
 *  some experimenting with uploading large files
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

package rogatkin.chatservlet;
import java.util.*;
import java.io.*;
import rogatkin.servlet.*;
import rogatkin.HttpUtils;
public class Input extends BaseFormProcessor {
	public final static String TF_PREF = "WebChat";
	public final static String PROP_POOLFOLDER = "POOLFOLDER";
	public final static String PROP_POOLPATH = "POOLPATH";
	public final static String PROP_URLHIGHLIGHT = "URLHIGHLIGHT";
	final static String HV_TEXT = "text";
	final static String HV_LOCK = "private";
	final static String HV_ATTACHMNT = "attachment";
	final static String HV_ENCODING = MessageBoardEditor.HV_ENCODING;
	final static String HV_USER = ":user";
	final static String PP_SENDTO = "sendto";

	protected Map producePageData() {
		return validateFormData();
	}
	
	protected Map validateFormData() {
		HashMap result = (HashMap)getSessionData();
		ChatRoom cr = (ChatRoom) getSession().getAttribute(getSession().getAttribute(USER_NAME).toString());
		String m = HttpUtils.htmlEncode(getStringParameterValue(HV_TEXT, "", 0));
		// TODO: this call has to be done only if corresponding option is active
		m = visualizeUrl(m);
		String a = getAttachment(new File(dispatcher.getProperty(PROP_POOLFOLDER, "."))
								 , dispatcher.getProperty(PROP_POOLPATH, "."));
		if (a != null && a.length() > 0)
			m += a;
		String sendTo = getStringParameterValue(PP_SENDTO, "", 0);
		result.put(HV_USER, sendTo);
		result.put(Entrance.HV_USER, sendTo.length() == 0?null:sendTo);
		if (m.length() > 0) {
		        if (dispatcher.getProperty(PROP_URLHIGHLIGHT)!= null)
	                        m = highlight(m);
			cr.addMessage(new Object[] {getSession().getAttribute(USER_NAME).toString(), m, "blue", new Date(), sendTo});
                }
		result.put(HV_ENCODING, cr.getEncoding());
		if (getStringParameterValue(HV_LOCK, null, 0) != null)
			cr.setLock(true);
		return result;
	}
	
	private String getAttachment(File _poolFolder, String _webPoolPath) {
		Object o = getObjectParameterValue(HV_ATTACHMNT, null, 0);
		if (o != null) {
			// write to attachment pool, assign name
			// TODO: consider that a returned object can be a file where 
			// an attachment is saved
			// consider downloading using just web server and spec download servlet
			// TODO: consider using getpathtranslated to figure file location
			try {
				String targetName = new File(getStringParameterValue(HV_ATTACHMNT+'+'+FILENAME, "None", 0)).getName();
				String ext = null;
				int dp = targetName.lastIndexOf('.');
				if (dp > 0)
					ext = targetName.substring(dp);
				File of = File.createTempFile(TF_PREF, ext, _poolFolder);
				of.deleteOnExit();
				OutputStream os = new FileOutputStream(of);
				if (o instanceof byte[])
					os.write((byte[])o);
				else if (o instanceof String)
					os.write(((String)o).getBytes()); // TODO: add encoding
				else if (o instanceof File) ;
				os.close();
				return "<a href=\""+_webPoolPath+of.getName()+"\">"
					+targetName 
					+"</a>"
					;
			} catch(IOException ioe) {
				ioe.printStackTrace();
			}
		}
		return null;
	}
	
	protected String getCharSet() {
		try {
			return ((ChatRoom) getSession().getAttribute(getSession().getAttribute(USER_NAME).toString())).getEncoding();
		} catch(NullPointerException npe) {
		}
		return null;
	}
	
	protected boolean onCancel() {
		getSession().invalidate();
		return super.onCancel();
	}
	
	protected String getTemplateName() {
		return "user_input.htm";
	}
	
	protected String getSubmitPage() {
		return null;
	}
	
	protected String getCancelPage() {
		return "Entrance";
	}
	
	protected String getExpiredPage() {
		return "Entrance"; // _top target
	}
	
	protected String highlight(String s) {
		return s;
	}

	/** Looking for URL like substring in string and convert them in 
	 * HTML anchor tag.
	 * The implementation has problem with URLs already in
	 * form of anchor tags
	 */
	public static String visualizeUrl(String _s) {
		// TODO: consider parser like version
		// look for ://, no mailto:, file:/ for first version
		int l = _s.length();
		if (l < 10)
			return _s;
		int cp = 0;
		int p = _s.indexOf("://", cp);
		if (p <= 0)
			return _s;
		StringBuffer result = new StringBuffer(l+50);
		do {
			if (p > 0) { // at least protocol 1 symbol				
				// look backward for first blank, but not so far
				int bp = -1;
				for (int j=p-1; j>=0 && p-j<6; j--)
					if (Character.isWhitespace (_s.charAt(j)) || Character.isLetterOrDigit( _s.charAt(j) ) == false)  {
						bp = j+1;
						break;
					} else if (j == 0)
						bp = j;
				if (bp >=0) { // look for ending
					int ep = -1;
					for (int k=p+3; k < l; k++)
						if (Character.isWhitespace (_s.charAt(k)) ||
							_s.charAt(k) == '"' || _s.charAt(k) == '>') {
							ep = k-1;
							break;
						} else if (k == l-1)
							ep = k;
					if (ep > 0) {
						if (bp > cp)
							result.append(_s.substring(cp, bp));
						result.append("<a href=\"").append(_s.substring(bp,ep+1));
						result.append("\">").append(_s.substring(bp,ep+1)).append("</a>");					
						if (ep < l-1)
							cp = ep+1;
						else 
							break;
					}
				} else
					cp = p + 1;
				p = _s.indexOf("://", cp);
			} else {
				result.append(_s.substring(cp));
				break;
			}
		} while(true);
		
		return result.toString();	
	}
}
