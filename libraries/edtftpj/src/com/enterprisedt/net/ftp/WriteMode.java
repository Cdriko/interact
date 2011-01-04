/**
 * 
 *  Copyright (C) 2007 Enterprise Distributed Technologies Ltd
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
 *    $Log: WriteMode.java,v $
 *    Revision 1.1  2007-12-18 07:52:06  bruceb
 *    2.0 changes
 *
 *
 */

package com.enterprisedt.net.ftp;

/**
 *  Enumerates the write modes that are possible when
 *  transferring files.
 *
 *  @author     Bruce Blackshaw
 *  @version    $Revision: 1.1 $
 *
 */
 public class WriteMode {

     /**
      *  Revision control id
      */
     public static final String cvsId = "@(#)$Id: WriteMode.java,v 1.1 2007-12-18 07:52:06 bruceb Exp $";

     /**
      *   Overwrite the file
      */
     public static final WriteMode OVERWRITE = new WriteMode("OVERWRITE");

     /**
      *   Append the file
      */
     public static final WriteMode APPEND = new WriteMode("APPEND");

     /**
      *   Resume the file
      */
     public static final WriteMode RESUME = new WriteMode("RESUME");
     
     /**
      *   Description of the write-mode
      */
     private String description;

     /**
      *  Private so no-one else can instantiate this class
      */
     private WriteMode(String description) {
    	 this.description = description;
     }
     
     public boolean equals(Object obj) {
         if (this == obj) return true;
         if (!(obj instanceof WriteMode )) return false;
         WriteMode mode = (WriteMode)obj;
         if (mode.description.equals(description)) return true;
         return false;
     }
     
     public String toString() {
    	 return description;
     }
 }
