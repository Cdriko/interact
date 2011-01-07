/* $RCSfile: Manageboard.java,v $
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
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  $Log: Manageboard.java,v $
 *  Revision 1.7  2001/02/01 08:14:37  dmitriy
 *  new message board impl
 *
 *  Revision 1.6  2001/01/23 00:32:56  dmitriy
 *  correct charset en/decoding of URL variables
 *
 *  Revision 1.5  2001/01/21 09:19:02  dmitriy
 *  fixed problem editing messages not in ASCII
 *  servlet path changed
 *
 *  Revision 1.4  2001/01/15 08:42:11  dmitriy
 *  added persistent for message board in cases of a server crashes
 *
 *  Revision 1.3  2001/01/11 23:34:32  dmitriy
 *  fixed HTML forms
 *  keeping private conversation after setting up a notification
 *  authorization fix
 *
 *  Revision 1.2  2001/01/11 10:01:02  dmitriy
 *  first implementation of message board in full
 *
 *  Revision 1.1  2001/01/11 05:02:27  dmitriy
 *  start work on message board feature
 *
 *
 */
package rogatkin.chatservlet;
import java.util.*;
import java.io.*;
import javax.servlet.http.*;

import rogatkin.servlet.*;

/** the class is used for management of message board at the front door of
 * the chat house
 */
public final class Manageboard extends MessageBoardEditor { 
	
	protected String getCharSet() {
		return "UTF-8";
	}

	protected String getTemplateName() {
		return "message_board_administrator.htm";
	}
	
	protected String getSubmitPage() {
		return "Manageboard";
	}
	
	protected String getCancelPage() {
		return getExpiredPage();
	}
	
	protected String getExpiredPage() {
		return "Entrance";
	}

	protected boolean isLoginForm() {
		return true;
	}
}
