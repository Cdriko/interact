/* $RCSfile: ChatServlet.java,v $
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
 *  $Log: ChatServlet.java,v $
 *  Revision 1.4  2005/08/24 22:52:37  rogatkin
 *  tuned to work with updated demrog
 *
 *  Revision 1.3  2001/02/01 08:14:36  dmitriy
 *  new message board impl
 *
 *  Revision 1.2  2001/01/15 08:42:11  dmitriy
 *  added persistent for message board in cases of a server crashes
 *
 *  Revision 1.1  2001/01/11 10:01:01  dmitriy
 *  first implementation of message board in full
 *
 */
package rogatkin.chatservlet;
import javax.servlet.*;
import rogatkin.servlet.*;
import java.io.IOException;
public final class ChatServlet extends FrontController implements MessageBoardCapable { 
	private NotificationEngine notificationEngine;
	private ChatRooms chatRooms;
	private MessageBoard messageBoard;
	public void init(ServletConfig _config) throws ServletException {
		super.init(_config);
		notificationEngine = new NotificationEngine(getProperties(), this);
		chatRooms = new ChatRooms(getProperties(), notificationEngine);
		messageBoard = new MessageBoard(getProperties());
		try {
			messageBoard.load();
		} catch(IOException ioe){
			log("IOException at reading messages ["+ioe);
		}
	}
	
	public NotificationEngine getNotificationEngine() {
		return notificationEngine;
	}
	
	public ChatRooms getChatRooms() {
		return chatRooms;
	}
	
	public MessageBoard getMessageBoard() {
		return messageBoard;
	}
        
        public void destroy() {
		try {
                     messageBoard.save();
		} catch(IOException ioe){
			log("IOException at saving messages ["+ioe);
		}
                super.destroy();
        }
}
