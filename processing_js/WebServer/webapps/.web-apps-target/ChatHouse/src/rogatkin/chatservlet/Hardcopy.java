/* $Id: Hardcopy.java,v 1.3 2001/01/09 04:39:27 dmitriy Exp $
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
 */
package rogatkin.chatservlet;
import java.io.*;
import java.util.Date;
import javax.servlet.http.*;
import rogatkin.servlet.*;
/** The class provides plain text copy of current chat log
 */
public final class Hardcopy implements PageServant {
	public void serve(final HttpServletRequest _req
							, HttpServletResponse _resp
							, Dispatcher _dispatcher )
		throws IOException {
		String name = _req.getSession().getAttribute(BaseFormProcessor.USER_NAME).toString();
		ChatRoom cr = (ChatRoom) _req.getSession().getAttribute(name);
		_resp.setContentType("text/plain; charset="+cr.getEncoding());
		PrintWriter out = _resp.getWriter();
		out.println(new Date());
		for (int i = 0; i < cr.size(); i++) {
			Object []m = (Object[])cr.get(i);
			if (m.length < 5 || m[4] == null || m[4].toString().length() == 0
				|| name.equals(m[4]) || name.equals(m[0]))
				out.println(m[0]+": "+m[1]);
		}
		out.checkError();
		out.close();
	}

	public boolean isThreadSafe() {
		return true;
	}
	
	public boolean isThreadFriendly() {
		return true;
	}
}
