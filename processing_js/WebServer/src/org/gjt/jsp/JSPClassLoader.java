/*
	GNUJSP - a free JSP implementation
	Copyright (C) 1998-1999, Vincent Partington <vinny@klomp.org>

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

package	org.gjt.jsp;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Hashtable;

import javax.servlet.ServletConfig;

public class JSPClassLoader extends ClassLoader {
	private File			repository;
	private ServletConfig	config;
	private boolean			debug;
	private Hashtable		classCache;

	public JSPClassLoader(File repository, ServletConfig config, boolean debug) {
		this.repository = repository;
		this.config = config;
		this.debug = debug;
		this.classCache = new Hashtable();
	}

	protected Class loadClass(String className, boolean resolve) throws ClassNotFoundException {
		Class c = (Class) classCache.get(className);

		if(c == null) {
			byte[] classData = loadClassData(className);
			if(classData != null) {
				c = defineClass(className, classData, 0, classData.length);
				if(debug) {
					config.getServletContext().log(className + " loaded by JSP class loader");
				}
			} else {
				ClassLoader cl = JSPServlet.class.getClassLoader(); 
				if (cl == null) { 
					c = findSystemClass(className); 
					if(debug) {
						config.getServletContext().log(className + " loaded by system class loader");
					}
				} else { 
					c = cl.loadClass(className);
					if(debug) {
						if(c.getClassLoader() == null) {
							config.getServletContext().log(className + " loaded by system class loader (through servlet class loader)");
						} else {
							config.getServletContext().log(className + " loaded by servlet class loader");
						}
					}
				}

				if(c == null) {
					if(debug) {
						config.getServletContext().log("failed to load " + className);
					}
					return null;
				}
			}
			classCache.put(className, c);
		}

		if(resolve) {
			resolveClass(c);
		}

		return c;
	}

	private byte[] loadClassData(String className) {
		File				classFile;
		DataInputStream		in;
		byte[]				classData;

		if(!className.startsWith("_jsp.")) {
			return null;
		}

		classFile = JSPCompiler.getFileForClass(repository, className, ".class");
		try {
			in = new DataInputStream(new FileInputStream(classFile));
			try {
				classData = new byte[(int) classFile.length()];
				in.readFully(classData, 0, classData.length);
				return classData;
			} finally {
				in.close();
			}
		} catch(IOException ioexc) {
			;
		}

		return null;
	}
}
