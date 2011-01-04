/**
 *
 *  edtFTPj
 * 
 *  Copyright (C) 2000-2004 Enterprise Distributed Technologies Ltd
 *
 *  www.enterprisedt.com
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *  Bug fixes, suggestions and comments should be should posted on 
 *  http://www.enterprisedt.com/forums/index.php
 *
 *  Change Log:
 *
 *    $Log: FTPMessageCollector.java,v $
 *    Revision 1.2  2005/06/03 11:26:25  bruceb
 *    comment change
 *
 *    Revision 1.1  2004/05/22 16:52:57  bruceb
 *    message listener
 *
 */

package com.enterprisedt.net.ftp;

/**
 *  Listens for and is notified of FTP commands and replies. 
 *
 *  @author      Bruce Blackshaw
 *  @version     $Revision: 1.2 $
 */
public class FTPMessageCollector implements FTPMessageListener {
    
    /**
     * Log of messages
     */
    private StringBuffer log = new StringBuffer();
    
    /**
     * Log an FTP command being sent to the server
     * 
     * @param cmd   command string
     */
    public void logCommand(String cmd) {
        log.append(cmd).append("\n");
    }
    
    /**
     * Log an FTP reply being sent back to the client
     * 
     * @param reply   reply string
     */
    public void logReply(String reply) {
        log.append(reply).append("\n");
    }
    
    /**
     * Get the log of messages
     * 
     * @return  message log as a string
     */
    public String getLog() {
        return log.toString();
    }
    
    /**
     * Clear the log of all messages
     */
    public void clearLog() {
        log = new StringBuffer();
    }

}
