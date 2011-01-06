/**
 *
 *  Java FTP client library.
 *
 *  Copyright (C) 2000  Enterprise Distributed Technologies Ltd
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
 *        $Log: TestTimeout.java,v $
 *        Revision 1.9  2007-08-09 00:10:52  hans
 *        Removed unused imports.
 *
 *        Revision 1.8  2005/07/15 17:30:06  bruceb
 *        rework of unit testing structure
 *
 *        Revision 1.7  2005/06/03 11:27:05  bruceb
 *        comment update
 *
 *        Revision 1.6  2004/08/31 10:44:49  bruceb
 *        minor tweaks re compile warnings
 *
 *        Revision 1.5  2004/05/01 17:05:43  bruceb
 *        Logger stuff added
 *
 *        Revision 1.4  2004/04/17 18:38:38  bruceb
 *        tweaks for ssl and new parsing functionality
 *
 *        Revision 1.3  2004/04/05 20:58:42  bruceb
 *        latest hans tweaks to tests
 *
 *        Revision 1.2  2003/05/31 14:54:05  bruceb
 *        cleaned up unused imports
 *
 *        Revision 1.1  2003/01/29 22:45:35  bruceb
 *        ??
 *
 *        Revision 1.1  2002/11/19 22:00:15  bruceb
 *        New JUnit test cases
 *
 *
 */

package com.enterprisedt.net.ftp.test;

import junit.framework.Test;
import junit.framework.TestSuite;

import com.enterprisedt.net.ftp.FTPTransferType;

/**
 *  Test timeout functionality. On a local network there is
 *  virtually no blocking, so ordinarily timeouts will not
 *  occur on network reads. We do this test in isolation and
 *  pull out a network cable to test the timeout
 *
 *  @author         Bruce Blackshaw
 *  @version        $Revision: 1.9 $
 */
public class TestTimeout extends FTPTestCase {

    /**
     *  Revision control id
     */
    public static String cvsId = "@(#)$Id: TestTimeout.java,v 1.9 2007-08-09 00:10:52 hans Exp $";

    /**
     *  Get name of log file
     *
     *  @return name of file to log to
     */
    protected String getLogName() {
        return "TestTimeout.log";
    }

    /**
     *  Test some general methods
     */
    public void testTimeout() throws Exception {
        
        connect();
        

        // move to test directory
        ftp.chdir(testdir);
        ftp.setType(FTPTransferType.BINARY);
        
        // put to a random filename
        String filename = generateRandomFilename();
        ftp.put(localDataDir + localBinaryFile, filename);

        // sleep - here we pull out the network!
        System.out.println("Disconnect network cable now!");
        Thread.sleep(30000);
        System.out.println("Trying to read - network should be disconnected");

        // get it back & delete remotely
        ftp.get(localDataDir + filename, filename);
        ftp.delete(filename);

        fail("Login should have failed with timeout!");
    }
    
    /**
     *  Automatic test suite construction
     *
     *  @return  suite of tests for this class
     */
    public static Test suite() {
        return new TestSuite(TestTimeout.class);
    }

    /**
     *  Enable our class to be run, doing the
     *  tests
     */
    public static void main(String[] args) {       
        junit.textui.TestRunner.run(suite());
    } 

}

