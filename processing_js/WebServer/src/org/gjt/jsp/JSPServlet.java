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

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class JSPServlet extends HttpServlet {
	boolean			correctlyInitialized = false;
	File			repository;
	String[]		compiler;
	boolean			checkDependencies = true;
	boolean			debug = false;
	String			defaultContentType = "text/html";
	boolean			checkUri = false;
	String			jspExtension = ".jsp";
	String			pageBase = "";

	JSPClassLoader	jspClassLoader;
	Hashtable		jspServlets;

	public void init(ServletConfig config) throws ServletException {
		super.init(config);

		String				s;
		Vector				v;
		StringTokenizer		toker;

		// get repository where generated java and class files are stored
		s = config.getInitParameter("repository");
		if(s == null) {
			throw new ServletException("mandatory init parameter repository has not been specified");
		}
		repository = new File(s);
		try {
			repository = new File(repository.getCanonicalPath());
		} catch(IOException ioexc) {
			repository = new File(repository.getAbsolutePath());
		}

		// get compiler command line
		s = config.getInitParameter("compiler");
		if(s == null) {
			s = "builtin-javac -classpath %classpath%" + File.pathSeparator +
				"%repository% -d %repository% -deprecation %source%";
		}
		v = new Vector();
		toker = new StringTokenizer(s);
		while(toker.hasMoreTokens()) {
			v.addElement(toker.nextToken());
		}
		if(v.size() <= 1) {
			throw new ServletException("init parameter compiler does not specify the compiler's parameters");
		}
		compiler = new String[v.size()];
		v.copyInto(compiler);		

		// get check dependency settings
		s = config.getInitParameter("checkdependencies");
		if(s != null && (s.equalsIgnoreCase("false") || s.equalsIgnoreCase("no"))) {
			checkDependencies = false;
		}

		// get debug setting
		s = config.getInitParameter("debug");
		if(s != null && (s.equalsIgnoreCase("true") || s.equalsIgnoreCase("yes"))) {
			debug = true;
		}

		// get default content-type
		s = config.getInitParameter("defaultcontenttype");
		if(s != null) {
			defaultContentType = s;
		}

 		s = config.getInitParameter("pagebase");
		if(s != null) {
			pageBase = s;
		}

		jspClassLoader = new JSPClassLoader(repository, config, debug);
		jspServlets = new Hashtable();
		correctlyInitialized = true;
	}

	protected void service(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
		int				i, j;
		File			jspFile;
		String			s, className;
		Servlet			srv;
		JSPCompiler		jspCompiler;

		if(!correctlyInitialized) {
			throw new ServletException("This servlet has not been initialized correctly");
		}

		try {
			jspFile = new File(request.getRealPath(request.getPathInfo()));
			try {
				jspFile = new File(jspFile.getCanonicalPath());
			} catch(IOException ioexc) {
				jspFile = new File(jspFile.getAbsolutePath());
			}
			className = JSPCompiler.getClassNameForJspFile(jspFile);

			// try to load jsp servlet from cache or class file
			srv = (Servlet) jspServlets.get(className);
			if(srv == null) {
				srv = loadServlet(className);
			}

			// unload servlet if dependencies demand it
			if(checkDependencies && srv != null) {
				if(checkServletDependencies(srv.getClass())) {
					unloadServlet(srv);
					refreshClassLoader(srv.getClass());
					srv = null;
				}
			}

			// compile & load jsp servlet if we haven't loaded it yet
			if(srv == null) {
				jspCompiler = new JSPCompiler(this, jspFile, className, request);
				jspCompiler.compile();

				srv = loadServlet(className);
				if(srv == null) {
					throw new JSPException("Could not load jsp servlet class " + className);
				}
			}
		} catch(JSPException jspexc) {
			if(debug) {
				getServletConfig().getServletContext().log(jspexc.getHttpErrorCode() + " JSP compile-time error: " + jspexc.getMessage());
			}
			response.setStatus(jspexc.getHttpErrorCode(), "JSP compile-time error");
			response.setContentType("text/html");
			PrintWriter out = response.getWriter();
			out.println("<HTML><HEAD><TITLE>" + jspexc.getHttpErrorCode() + " JSP compile-time error</TITLE></HEAD><BODY>" +
						"<H2>" + jspexc.getHttpErrorCode() + " JSP compile-time error</H2>" +
						"The JSP page you requested could not be served because the following error(s) occured:<BR><PRE>");
			out.println(jspexc.getMessage());
			out.println("</PRE></BODY></HTML>");
			out.close();
			return;
		}

		// run jsp servlet
		srv.service(request, response);
	}

	public void destroy() {
		super.destroy();

		if(correctlyInitialized) {
			Enumeration		e;
			Servlet			srv;
	
			e = jspServlets.elements();
			while(e.hasMoreElements()) {
				srv = (Servlet) e.nextElement();
				unloadServlet(srv);
			}
		}
	}

	public String getServletInfo() {
		return "GNUJSP JSPServlet";
	}

	private Servlet loadServlet(String className) throws JSPException {
		Class		c;
		Field		fld;
		Servlet		srv;

		// load servlet class
		try {
			c = jspClassLoader.loadClass(className);
			if(c == null)
				return null;
		} catch(ClassNotFoundException cnfexc) {
			return null;
		}

		// check compiler version dependency
		try {
			fld = c.getField("__compilerVersionNr");
			if(fld.getInt(null) != JSPCompiler.COMPILER_VERSION_NR) {
				refreshClassLoader(c);
				return null;
			}
		} catch(IllegalAccessException fiaexc) {
			throw new JSPException("Jsp servlet class " + className + " does not have a public static __compilerVersionNr field");
		} catch(NoSuchFieldException nsfexc) {
			throw new JSPException("Jsp servlet class " + className + " does not have a __compilerVersionNr field of type int");
		} catch(SecurityException secexc) {
			throw new JSPException("Jsp servlet class " + className + " has a security problem with its __compilerVersionNr field");
		}

		// check servlet's other dependencies
		if(checkDependencies && checkServletDependencies(c)) {
			refreshClassLoader(c);
			return null;
		}

		// instantiate servlet
		try {
			srv = (Servlet) c.newInstance();
		} catch(IllegalAccessException iaexc) {
			throw new JSPException("Could not instantiate jsp servlet class " + className + " because of an illegal access exception");
		} catch(InstantiationException iexc) {
			throw new JSPException("Could not instantiate jsp servlet class " + className + " because it is an interface or an abstract class");
		}

		// init servlet
		try {
			srv.init(getServletConfig());
		} catch(Exception exc) {}

		jspServlets.put(className, srv);

		return srv;
	}

	private void unloadServlet(Servlet srv) {
		try {
			srv.destroy();
		} catch(Exception exc) { }

		jspServlets.remove(srv.getClass().getName());
	}

	private boolean checkServletDependencies(Class c) throws JSPException {
		Method			meth;

		try {
			// invoke dependency checking method
			meth = c.getMethod("__checkDependencies", new Class[0]);
			return ((Boolean) meth.invoke(null, new Object[0])).booleanValue();
		} catch(IllegalAccessException iaexc) {
			throw new JSPException("Jsp servlet class " + c.getName() + " does not have a public static __checkDependencies() method");
		} catch(InvocationTargetException itexc) {
			throw new JSPException("Jsp servlet class " + c.getName() + "'s __checkDependencies() method threw an exception: " + itexc.getTargetException());
		} catch(NoSuchMethodException nsfexc) {
			throw new JSPException("Jsp servlet class " + c.getName() + " does not have a __checkDependencies() method that returns a boolean");
		} catch(SecurityException secexc) {
			throw new JSPException("Jsp servlet class " + c.getName() + " has a security problem with its __checkDependencies() method");
		}
	}

	private void refreshClassLoader(Class c) {
		if(c.getClassLoader() == jspClassLoader) {
			jspClassLoader = new JSPClassLoader(repository, getServletConfig(), debug);
		}
	}

	private static String urlDecode(String val) {
        StringBuffer	buf = new StringBuffer(val.length());
        char			c;

		for (int i = 0; i < val.length(); i++) {
			c = val.charAt(i);
			if(c == '%') {
				try {
					buf.append((char)Integer.parseInt(val.substring(i+1,i+3),16));
					i += 2;
					continue;
				} catch(Exception e) { }
			} else if(c == '+') {
				buf.append(' ');
				continue;
			}
 			buf.append(c);
		}
        return buf.toString();
	}
}
