/**
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
 *  Bug fixes, suggestions and comments should be sent to bruce@enterprisedt.com
 *
 *  Change Log:
 *
 *    $Log: FileAppender.java,v $
 *    Revision 1.6  2007-04-26 04:21:47  hans
 *    Keep reference to File object.
 *
 *    Revision 1.5  2006/10/12 12:38:58  bruceb
 *    synchronized methods
 *
 *    Revision 1.4  2006/10/11 08:43:11  hans
 *    made cvsId final
 *
 *    Revision 1.3  2005/01/28 16:39:15  bruceb
 *    flush FileAppender
 *
 *    Revision 1.2  2004/08/16 21:08:08  bruceb
 *    made cvsids public
 *
 *    Revision 1.1  2004/05/01 16:55:42  bruceb
 *    first cut
 *
 *
 */
package com.enterprisedt.util.debug;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

/**
 *  Appends log statements to a file
 *
 *  @author      Bruce Blackshaw
 *  @version     $Revision: 1.6 $
 */
public class FileAppender implements Appender {
    
    /**
     *  Revision control id
     */
    public final static String cvsId = "@(#)$Id: FileAppender.java,v 1.6 2007-04-26 04:21:47 hans Exp $";

    /**
     * Destination
     */
    private PrintWriter log;
    
    /**
     * Path of logging file.
     */
    private String file;
    
    /**
     * Constructor
     * 
     * @param file      file to log to
     * @throws IOException
     */
    public FileAppender(String file) throws IOException {
        log = new PrintWriter(new FileWriter(file, true), true);
        this.file = file;
    }
    
    /**
     * Log a message
     * 
     * @param msg  message to log
     */
    public synchronized void log(String msg) {
        log.println(msg);
    }
    
    /* (non-Javadoc)
     * @see com.enterprisedt.util.debug.Appender#log(java.lang.Throwable)
     */
    public synchronized void log(Throwable t) {
        t.printStackTrace(log);
        log.println();
        
    }

    /* (non-Javadoc)
     * @see com.enterprisedt.util.debug.Appender#close()
     */
    public synchronized void close() {
        log.flush();
        log.close();
    }

    /**
     * Returns the path of the logging file.
     * 
     * @return the path of the logging file.
     */
    public String getFile() {
		return file;
	}
}
