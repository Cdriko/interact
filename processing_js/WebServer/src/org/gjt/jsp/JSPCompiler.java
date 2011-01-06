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

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Properties;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import Acme.Utils;

/**
 * This JSP compiler class takes the quick&dirty approach to JSP parsing.
 * The whole JSP file is read into memory and an index is run through it
 * until a StringIndexOutOfBoundsException occurs. I was happily hacking
 * away at this until I discovered it had gotten more than 30K long. It
 * seems to work, but someday it might be a good idea to break this
 * all up into separate classes, like a JSPParser, JavaGenerator en
 * JavaCompiler class.
 *
 * A new JSPCompiler should be created every time a file is compiled.
 * The classfiles directory, the file and the classname are parameters
 * to the constructor. Call compile() to do the actual compiling.
 */
public class JSPCompiler {
	public static final int	COMPILER_VERSION_NR = 4;

	private static final int	PARSE_NONE = 0,
								PARSE_HTML = 1,
								PARSE_DECLARATION = 2,
								PARSE_SCRIPTLET = 3,
								PARSE_EXPRESSION = 4;

	private static final String	lineSeparator = System.getProperty("line.separator"),
								encodedLineSeparator = javaStringEncode(System.getProperty("line.separator"));

	private JSPServlet			jspServlet;
	private File				jspFile, javaFile, classFile;
	private String				className;
	private HttpServletRequest	servletRequest;

	private String				src;
	private int					srcPos, lineNr;

	private int					parseState = PARSE_NONE;
	private boolean				justWroteNewline = false;

	private Vector				dependencies = new Vector();
	private boolean				createSession = false;
	private String				content_typeDirective = null;
	private StringBuffer		extendsDirective = new StringBuffer(),
								implementsDirective = new StringBuffer(),
								importDirective = new StringBuffer(),
								methodDirective = new StringBuffer(),
								declarationsCode = new StringBuffer(),
								beanCode = new StringBuffer(),
								scriptletsCode = new StringBuffer();

	/**
	 * Create a JSPCompiler object.
	 */
	public JSPCompiler(JSPServlet jspServlet, File jspFile, String className, HttpServletRequest servletRequest) {
		this.jspServlet = jspServlet;
		this.jspFile = jspFile;
		this.javaFile = getFileForClass(jspServlet.repository, className, ".java");
		this.classFile = getFileForClass(jspServlet.repository, className, ".class");
		this.className = className;
		this.servletRequest = servletRequest;
	}

	/**
	 * Do the actual compilation. This is done in three phases:
	 * <OL>
	 * <LI>parse the JSP file
	 * <LI>generate a <CODE>.java</CODE> file
	 * <LI>compile the <CODE>.java</CODE> file into a <CODE>.class</CODE> file
	 * </OL>
	 *
	 * @exception JSPException is thrown when a compilation error occurs
	 */
	public void compile() throws JSPException {
		parseJspFile();
		generateJavaFile();
		compileJavaFile();
	}

	private void parseJspFile() throws JSPException {
		parseOneJspFile();
		changeParseState(PARSE_NONE);

		if(content_typeDirective == null) {
			content_typeDirective = jspServlet.defaultContentType;
		}
		if(extendsDirective.length() == 0) {
			extendsDirective.append("javax.servlet.http.HttpServlet");
		}
		if(methodDirective.length() == 0) {
			methodDirective.append("service");
		}
	}

	private void parseOneJspFile() throws JSPException {
		BufferedReader	in;
		StringBuffer	srcBuf;
		String			s;
		int				i;
		char			c, d;

		// read jsp source
		dependencies.addElement(jspFile);
		dependencies.addElement(new Long(jspFile.lastModified()));
		try {
			in = new BufferedReader(new FileReader(jspFile));
			try {
				srcBuf = new StringBuffer((int) jspFile.length());
				while((s = in.readLine()) != null) {
					srcBuf.append(s).append((char) '\n');
				}
				src = srcBuf.toString();
				srcBuf = null;
			} finally {
				in.close();
			}
		} catch(FileNotFoundException fnfexc) {
			throw new JSPException(HttpServletResponse.SC_NOT_FOUND, "File " + jspFile + " could not be found");
		} catch(IOException ioexc) {
			throw new JSPException(ioexc.toString());
		}

		// parse jsp source
		lineNr = 1;
		srcPos = 0;
		try {
			PARSING: for(;;) {
				c = src.charAt(srcPos);

				// check for possible state change
				if(c == '<') {
					if(parseState == PARSE_NONE || parseState == PARSE_HTML) {
						if(parseInNoneOrHtmlState()) {
							continue PARSING;
						}
					} else if(parseState == PARSE_DECLARATION) {
						if(parseInDeclarationState()) {
							continue PARSING;
						}
					}
				} else if(c == '%' &&
					(parseState == PARSE_EXPRESSION || parseState == PARSE_SCRIPTLET) &&
					(srcPos < src.length()-1 && src.charAt(srcPos+1) == '>'))
				{
					// end of expression or scriptlet
					changeParseState(PARSE_NONE);
					srcPos += 2;
					continue PARSING;
				}

				// output character
				switch(parseState) {
				case PARSE_NONE:
					changeParseState(PARSE_HTML);
				case PARSE_HTML:
					if(justWroteNewline && c != '\n') {
						justWroteNewline = false;
						scriptletsCode.append("\" +").append(lineSeparator).append("\t\t\t\"");
					}

					switch(c) {
					case '\b':
						scriptletsCode.append("\\b");
						break;
					case '\t':
						scriptletsCode.append("\\t");
						break;
					case '\n':
						scriptletsCode.append(encodedLineSeparator);
						justWroteNewline = true;
						lineNr++;
						break;
					case '\f':
						scriptletsCode.append("\\f");
						break;
					case '\'':
						scriptletsCode.append("\\\'");
						break;
					case '\"':
						scriptletsCode.append("\\\"");
						break;
					case '\\':
						scriptletsCode.append("\\\\");
						break;
					default:
						if(c > 0xFF) {
							s = "00" + Integer.toHexString(c);
							scriptletsCode.append("\\u").append(s.substring(s.length() - 4));
						} else if(c < ' ' || c >= 0x7F) {
							s = "00" + Integer.toOctalString(c);
							scriptletsCode.append((char) '\\').append(s.substring(s.length() - 3));
						} else {
							scriptletsCode.append((char) c);
						}
						break;
					}
					break;
				case PARSE_DECLARATION:
					if(c == '\n') {
						declarationsCode.append(lineSeparator);
						lineNr++;
					} else {
						declarationsCode.append((char) c);
					}
					break;
				default:
					if(c == '\n') {
						scriptletsCode.append(lineSeparator);
						lineNr++;
					} else {
						scriptletsCode.append((char) c);
					}
					break;
				}
				srcPos++;
			}
		} catch(StringIndexOutOfBoundsException sioobexc) {
			// instead of checking for the end of the string ourselves
			// we let java.lang.String find it. This makes the code
			// simpeler and more efficient.
		}
	}

	private boolean parseInNoneOrHtmlState() throws StringIndexOutOfBoundsException, JSPException {
		String[]	keyAndValue;
		char		d;

		if(srcPos < src.length()-3 && src.charAt(srcPos+1) == '%') {
			// directive or start of expression or scriptlet
			d = src.charAt(srcPos+2);
			if(d == '=') {
				// start of expression
				changeParseState(PARSE_EXPRESSION);
				setSrcPos(srcPos+3);
				return true;
			} else if(d == '@') {
				// directive
				parseDirective();
				return true;
			} else {
				// start of scriplet
				changeParseState(PARSE_SCRIPTLET);
				setSrcPos(srcPos+2);
				return true;
			}
		} else if(srcPos < src.length()-20 &&
					src.substring(srcPos+1, srcPos+12).equalsIgnoreCase("!--#INCLUDE") &&
					Character.isWhitespace(src.charAt(srcPos+12)))
		{
			parseSSI();
			return true;
		} else if(srcPos < src.length()-20 &&
					src.substring(srcPos+1, srcPos+7).equalsIgnoreCase("SCRIPT") &&
					Character.isWhitespace(src.charAt(srcPos+7)))
		{
			// possible start of declaration
			boolean	runatServer = false;
			int		prevSrcPos = srcPos,
					prevLineNr = lineNr;

			srcPos += 7;
			skipWhitespace();
			for(;;) {
				// check for end of tag
				if(src.charAt(srcPos) == '>') {
					if(runatServer) {
						// start of declaration
						changeParseState(PARSE_DECLARATION);
						srcPos++;
						return true;
					} else {
						srcPos = prevSrcPos;
						lineNr = prevLineNr;
						return false;
					}
				}
				keyAndValue = parseKeyAndValue();
				if(keyAndValue[0].equalsIgnoreCase("RUNAT") && keyAndValue[1].equalsIgnoreCase("SERVER")) {
					runatServer = true;
				}
			}
		} else if(srcPos < src.length()-10 &&
					src.substring(srcPos+1, srcPos+5).equalsIgnoreCase("BEAN") &&
					Character.isWhitespace(src.charAt(srcPos+5)))
		{
			// bean
			parseBean();
			return true;
		}

		return false;
	}

	private boolean parseInDeclarationState() throws StringIndexOutOfBoundsException, JSPException {
		if(srcPos < src.length()-8 &&
				src.substring(srcPos+1, srcPos+8).equalsIgnoreCase("/SCRIPT") &&
				(Character.isWhitespace(src.charAt(srcPos+8)) || src.charAt(srcPos+8) == '>'))
		{
			// end of declaration
			changeParseState(PARSE_NONE);
			setSrcPos(src.indexOf('>', srcPos));
			srcPos++;
			return true;
		}
		return false;
	}

	private void parseDirective() throws StringIndexOutOfBoundsException, JSPException {
		String[]		keyAndValue;
		StringTokenizer	toker;
		char			c;

		srcPos += 3;
		skipWhitespace();

		for(;;) {
			// check for end of directive
			c = src.charAt(srcPos);
			if(c == '%') {
				if(src.charAt(srcPos+1) == '>') {
					srcPos += 2;
				} else {
					srcPos++;
				}
				return;
			} else if(c == '>') {
				srcPos++;
				return;
			}

			keyAndValue = parseKeyAndValue();

			if(keyAndValue[0].equalsIgnoreCase("content_type")) {
				// content_type
				if(content_typeDirective == null) {
					content_typeDirective = keyAndValue[1];
				}
			} else if(keyAndValue[0].equalsIgnoreCase("extends")) {
				// extends
				if(extendsDirective.length() == 0) {
					extendsDirective.append(lineSeparator);
					recordFileAndLineNr(extendsDirective);
					extendsDirective.append(keyAndValue[1]);
				}
			} else if(keyAndValue[0].equalsIgnoreCase("implements")) {
				// implements
				toker = new StringTokenizer(keyAndValue[1], " ,");
				while(toker.hasMoreTokens()) {
					if(implementsDirective.length() == 0) {
						implementsDirective.append(" implements").append(lineSeparator);
					} else {
						implementsDirective.append(",").append(lineSeparator);
					}
					recordFileAndLineNr(implementsDirective);
					implementsDirective.append(toker.nextToken());
				}
			} else if(keyAndValue[0].equalsIgnoreCase("import")) {
				// import
				toker = new StringTokenizer(keyAndValue[1], " ,");
				while(toker.hasMoreTokens()) {
					recordFileAndLineNr(importDirective);
					importDirective.append("import ").append(toker.nextToken()).append((char) ';').append(lineSeparator);
				}
			} else if(keyAndValue[0].equalsIgnoreCase("include")) {
				// include
				parseInclude(keyAndValue[1], false);
			} else if(keyAndValue[0].equalsIgnoreCase("language")) {
				// language
				if(!keyAndValue[1].equalsIgnoreCase("java")) {
					throw new JSPException("<B>" + jspFile.getPath() + ":" + lineNr + "</B>: Unknown jsp language " + keyAndValue[1]);
				}
			} else if(keyAndValue[0].equalsIgnoreCase("method")) {
				// method
				if(methodDirective.length() == 0) {
					methodDirective.append(lineSeparator);
					recordFileAndLineNr(methodDirective);
					methodDirective.append(keyAndValue[1]);
				}
			} else if(keyAndValue[0].equalsIgnoreCase("vinclude")) {
				// vinclude
				parseInclude(keyAndValue[1], true);
			} else {
				throw new JSPException("<B>" + jspFile.getPath() + ":" + lineNr + "</B>: Unknown jsp directive '<I>" + keyAndValue[0] + "</I>'");
			}
		}
	}

	private void parseSSI() throws StringIndexOutOfBoundsException, JSPException {
		String[]		keyAndValue;

		srcPos += 12;
		skipWhitespace();
		keyAndValue = parseKeyAndValue();

		if(keyAndValue[0].equalsIgnoreCase("FILE")) {
			parseInclude(keyAndValue[1], false);
		} else if(keyAndValue[0].equalsIgnoreCase("VIRTUAL")) {
			parseInclude(keyAndValue[1], true);
		} else {
			throw new JSPException("<B>" + jspFile.getPath() + ":" + lineNr + "</B>: Unknown #INCLUDE parameter " + keyAndValue[0]);
		}

		setSrcPos(src.indexOf('>', srcPos));
		srcPos++;
	}

	private void parseInclude(String value, boolean virtual) throws StringIndexOutOfBoundsException, JSPException {
		File			prevJspFile;
		String			s, prevSrc;
		int				prevSrcPos, prevLineNr;

		prevJspFile = jspFile;
		prevSrc = src;
		prevSrcPos = srcPos;
		prevLineNr = lineNr;

		try {
			if(virtual) {
				s = servletRequest.getRealPath(value);
				if(s == null)
					throw new JSPException("<B>" + jspFile.getPath() + ":" + lineNr + "</B>: Virtual file " + value + " could not be mapped to a real file");
				jspFile = new File(s);
			} else {
				jspFile = new File(jspFile.getParent(), value);
			}
			try {
				jspFile = new File(jspFile.getCanonicalPath());
			} catch(IOException ioexc) {
				jspFile = new File(jspFile.getAbsolutePath());
			}
			parseOneJspFile();
		} finally {
			jspFile = prevJspFile;
			src = prevSrc;
			srcPos = prevSrcPos;
			lineNr = prevLineNr;
		}
	}

	private void parseBean() throws StringIndexOutOfBoundsException, JSPException {
		Properties		beanAttributes;
		Hashtable		beanDefaultProperties;
		Enumeration		e;
		String[]		keyAndValue;
		String			k, v, name, varName, type, introspect,
						create, scope, beanName, getFromScope;
		int				startLineNr, endLineNr, i;

		startLineNr = lineNr;
		srcPos += 5;
		skipWhitespace();

		// gather <BEAN> tag parameters
		beanAttributes = new Properties();
		for(;;) {
			// check for end of tag
			if(src.charAt(srcPos) == '>') {
				break;
			}
			keyAndValue = parseKeyAndValue();
			beanAttributes.put(keyAndValue[0].toLowerCase(), keyAndValue[1]);
		}

		// gather <PARAM> tags
		beanDefaultProperties = new Hashtable();
		for(;;) {
			setSrcPos(src.indexOf('<', srcPos));
			if(src.substring(srcPos+1, srcPos+6).equalsIgnoreCase("/BEAN") &&
				(Character.isWhitespace(src.charAt(srcPos+6)) || src.charAt(srcPos+6) == '>'))
			{
				// </BEAN> tag
				setSrcPos(src.indexOf('>', srcPos));
				srcPos++;
				break;
			} else if(src.substring(srcPos+1, srcPos+6).equalsIgnoreCase("PARAM") &&
				Character.isWhitespace(src.charAt(srcPos+6)))
			{
				// <PARAM> tag
				srcPos += 6;
				skipWhitespace();

				for(;;) {
					// check for end of tag
					if(src.charAt(srcPos) == '>') {
						break;
					}
					keyAndValue = parseKeyAndValue();
					beanDefaultProperties.put(keyAndValue[0], keyAndValue[1]);
				}
			} else {
				srcPos++;
			}
		}

		// check bean attributes
		name = beanAttributes.getProperty("name");
		if(name == null)
			throw new JSPException("<B>" + jspFile.getPath() + ":" + lineNr + "</B>: &lt;BEAN&gt; tag does not have required name attribute");
		varName = beanAttributes.getProperty("varname", name);
		type = beanAttributes.getProperty("type", "Object");
		introspect = beanAttributes.getProperty("introspect", "yes");
		create = beanAttributes.getProperty("create", "yes");
		scope = beanAttributes.getProperty("scope", "request");
		beanName = beanAttributes.getProperty("beanname", type);
		if(scope.equals("request")) {
			getFromScope = "request.getAttribute(\"";
		} else if(scope.equals("session")) {
			createSession = true;
			getFromScope = "__session.getValue(\"";
		} else {
			throw new JSPException("<B>" + jspFile.getPath() + ":" + lineNr + "</B>: &lt;BEAN&gt; tag has invalid scope attribute " + scope);
		}

		// generate bean code
		endLineNr = lineNr;
		try {
			// put back line number for start of <BEAN> tag
			lineNr = startLineNr;

			if(beanCode.length() == 0) {
				beanCode.append("\t\tjava.beans.PropertyDescriptor[] __propertyDescriptors;").append(lineSeparator);
			}

			// bean retrieval
			recordFileAndLineNr(beanCode);
			beanCode.append("\t\t").append(type).append((char) ' ').append(varName)
					.append(" = null;").append(lineSeparator);

			recordFileAndLineNr(beanCode);
			beanCode.append("\t\t").append("if(").append(getFromScope).append(javaStringEncode(name))
					.append("\") instanceof ").append(type).append(") {").append(lineSeparator);

			recordFileAndLineNr(beanCode);
			beanCode.append("\t\t\t").append(varName).append(" = (").append(type).append(") ")
					.append(getFromScope).append(javaStringEncode(name)).append("\");").append(lineSeparator);

			beanCode.append("\t\t} else {").append(lineSeparator);

			if(create.equalsIgnoreCase("yes")) {
				// bean creation
				beanCode.append("\t\t\ttry {").append(lineSeparator);

				recordFileAndLineNr(beanCode);
				beanCode.append("\t\t\t\t").append(varName).append(" = (").append(type)
						.append(") ").append("java.beans.Beans.instantiate(this.getClass().getClassLoader(), \"")
						.append(beanName).append("\");").append(lineSeparator);;

				if(scope.equals("session")) {
					recordFileAndLineNr(beanCode);
					beanCode.append("\t\t\t\t__session.putValue(\"").append(javaStringEncode(name)).append("\", ")
							.append(varName).append(");").append(lineSeparator);
 				}

				beanCode.append("\t\t\t} catch(java.lang.ClassNotFoundException cnfexc) {").append(lineSeparator);

				beanCode.append("\t\t\t\t__beanError(response, \"Could not create bean ").append(javaStringEncode(name))
						.append(" of type ").append(javaStringEncode(type)).append(" (class not found)\");").append(lineSeparator);

				beanCode.append("\t\t\t\treturn;").append(lineSeparator);

				beanCode.append("\t\t\t}").append(lineSeparator);
			} else {
				recordFileAndLineNr(beanCode);
				beanCode.append("\t\t\t__beanError(response, \"Bean ").append(javaStringEncode(name))
						.append(" does not exist or is not of type ").append(javaStringEncode(type)).append("\");").append(lineSeparator);

				beanCode.append("\t\t\treturn;");
			}

			beanCode.append("\t\t}").append(lineSeparator);

			if(beanDefaultProperties.size() > 0 || introspect.equalsIgnoreCase("yes")) {
				beanCode.append("\t\ttry {").append(lineSeparator);

				recordFileAndLineNr(beanCode);
				beanCode.append("\t\t\t__propertyDescriptors = java.beans.Introspector.getBeanInfo(")
						.append(varName).append(".getClass()).getPropertyDescriptors();").append(lineSeparator);

				// set bean default properties
				e = beanDefaultProperties.keys();
				while(e.hasMoreElements()) {
					k = (String) e.nextElement();
					v = (String) beanDefaultProperties.get(k);

					recordFileAndLineNr(beanCode);
					beanCode.append("\t\t\tif(!__beanSetProperty(").append(varName)
							.append(", __propertyDescriptors, \"").append(javaStringEncode(k))
							.append("\", \"").append(javaStringEncode(v)).append("\")) {").append(lineSeparator);

					beanCode.append("\t\t\t\t__beanError(response, \"Bean ").append(javaStringEncode(name))
							.append(" of type").append(javaStringEncode(type)).append(" has no property named ")
							.append(javaStringEncode(k)).append("\");").append(lineSeparator);

					beanCode.append("\t\t\t\treturn;").append(lineSeparator);

					beanCode.append("\t\t\t}").append(lineSeparator);
				}

				// do bean introspection
				if(introspect.equalsIgnoreCase("yes")) {
					recordFileAndLineNr(beanCode);
					beanCode.append("\t\t\t__beanIntrospect(").append(varName)
							.append(", __propertyDescriptors, request);").append(lineSeparator);
				}

				beanCode.append("\t\t} catch(java.beans.IntrospectionException introexc) {").append(lineSeparator);

				beanCode.append("\t\t\t__beanError(response, \"Introspection failed for bean ")
						.append(javaStringEncode(name)).append(" of type ").append(javaStringEncode(type))
						.append("\");").append(lineSeparator);

				beanCode.append("\t\t}").append(lineSeparator);
			}
			beanCode.append(lineSeparator);
		} finally {
			lineNr = endLineNr;
		}
	}

	private String[] parseKeyAndValue() throws StringIndexOutOfBoundsException {
		char		c;
		int			pos;
		String[]	keyAndValue = new String[2];

		// gather key
		pos = srcPos;
		for(;;) {
			c = src.charAt(srcPos);
			if(c == '=' || Character.isWhitespace(c)) {
				break;
			}
			srcPos++;
		}
		keyAndValue[0] = src.substring(pos, srcPos);
		skipWhitespace();
		// quick work around page processing		if ("page".equals(keyAndValue[0]))
			return parseKeyAndValue();		
		// gather optional value
		if(src.charAt(srcPos) == '=') {
			srcPos++;
			skipWhitespace();

			c = src.charAt(srcPos);
			if(c == '\'' || c == '\"') {
				pos = src.indexOf(c, srcPos+1);
				keyAndValue[1] = src.substring(srcPos+1, pos);
				setSrcPos(pos+1);
			} else {
				pos = srcPos;
				for(;;) {
					c = src.charAt(srcPos);
					if(c == '%' || c == '>' || Character.isWhitespace(c)) {
						break;
					}
					srcPos++;
				}
				keyAndValue[1] = src.substring(pos, srcPos);
			}

			skipWhitespace();
		} else {
			keyAndValue[1] = keyAndValue[0];
		}

		return keyAndValue;
	}

	private void changeParseState(int newState) {
		if(newState == parseState)
			return;

		switch(parseState) {
		case PARSE_HTML:
			scriptletsCode.append("\");").append(lineSeparator);
			break;
		case PARSE_EXPRESSION:
			scriptletsCode.append("));").append(lineSeparator);
			break;
		case PARSE_DECLARATION:
			declarationsCode.append(lineSeparator);
			break;
		case PARSE_SCRIPTLET:
			scriptletsCode.append(lineSeparator);
			break;
		}

		parseState = newState;

		switch(parseState) {
		case PARSE_HTML:
			recordFileAndLineNr(scriptletsCode);
			scriptletsCode.append("\t\t\tout.print(\"");
			break;
		case PARSE_EXPRESSION:
			recordFileAndLineNr(scriptletsCode);
			scriptletsCode.append("\t\t\tout.print(__valueOf(");
			break;
		case PARSE_DECLARATION:
			recordFileAndLineNr(declarationsCode);
			break;
		case PARSE_SCRIPTLET:
			recordFileAndLineNr(scriptletsCode);
			break;
		}
	}

	private void recordFileAndLineNr(StringBuffer code) {
		// FIXME: do nice encoding of backslashes in filename
		code.append("//line " + jspFile.toString().replace('\\', '/') + ":" + lineNr).append(lineSeparator);
	}

	private void skipWhitespace() {
		char		c;

		for(;;) {
			c = src.charAt(srcPos);
			if(!Character.isWhitespace(c)) {
				break;
			} else if(c == '\n') {
				lineNr++;
			}
			srcPos++;
		}
	}

	private void setSrcPos(int newSrcPos) {
		int			from;

		if(newSrcPos < 0 || newSrcPos >= src.length())
			throw new StringIndexOutOfBoundsException(Integer.toString(newSrcPos));

		from = srcPos-1;
		for(;;) {
			from = src.indexOf('\n', from+1);
			if(from == -1 || from >= newSrcPos) {
				break;
			}
			lineNr++;
		}
		srcPos = newSrcPos;
	}

	private void generateJavaFile() throws JSPException {
		PrintWriter 	out;
		Enumeration		e;
		File			f;
		String			pn, cn;
		Long			l;
		int				i;

		try {
			f = new File(javaFile.getParent());
			f.mkdirs();
			out = new PrintWriter(new FileWriter(javaFile));
			i = className.lastIndexOf('.');
			if(i > 0) {
				pn = className.substring(0, i);
				cn = className.substring(i+1);
			} else {
				pn = null;
				cn = className;
			}
			try {
				// generate header and start of class
				out.println("/* Automatically generated by GNUJSP. Do not edit. */");
				if(pn != null) {
					out.println("package " + pn + ";");
				}
				out.println(importDirective);
				out.println("public final class " + cn +
							" extends " + extendsDirective + implementsDirective);
				out.println("{");

				// generate declarations
				out.println(declarationsCode);

				// generate specified method
				out.println("\tpublic void " + methodDirective +
							"(javax.servlet.http.HttpServletRequest request, " +
							"javax.servlet.http.HttpServletResponse response) " +
							"throws javax.servlet.ServletException, java.io.IOException");
				out.println("\t{");
				if(createSession) {
					out.println("\t\tjavax.servlet.http.HttpSession __session = request.getSession(true);");
				}
				out.println(beanCode);
				out.println("\t\tresponse.setContentType(\"" + javaStringEncode(content_typeDirective) + "\");");
				out.println("\t\tjava.io.PrintWriter out = response.getWriter();");
				out.println("\t\ttry {");
				out.println(scriptletsCode);
				out.println("\t\t} finally {");
				out.println("\t\t\tout.flush();");
				out.println("\t\t\tout.close();");
				out.println("\t\t}");
				out.println("\t}");
				out.println();

				// generate own version of String.valueOf()
				out.println("\tprivate static java.lang.String __valueOf(java.lang.Object obj) {");
				out.println("\t\tif(obj == null) {");
				out.println("\t\t\treturn \"\";");
				out.println("\t\t} else {");
				out.println("\t\t\treturn obj.toString();");
				out.println("\t\t}");
				out.println("\t}");
				out.println("\tprivate static java.lang.String __valueOf(boolean b) { return java.lang.String.valueOf(b); }");
				out.println("\tprivate static java.lang.String __valueOf(char c)    { return java.lang.String.valueOf(c); }");
				out.println("\tprivate static java.lang.String __valueOf(int i)     { return java.lang.String.valueOf(i); }");
				out.println("\tprivate static java.lang.String __valueOf(long l)    { return java.lang.String.valueOf(l); }");
				out.println("\tprivate static java.lang.String __valueOf(float f)   { return java.lang.String.valueOf(f); }");
				out.println("\tprivate static java.lang.String __valueOf(double d)  { return java.lang.String.valueOf(d); }");
				out.println();

				// generate bean functions
				out.println("\tprivate void __beanError(javax.servlet.http.HttpServletResponse response, java.lang.String msg) throws java.io.IOException {");
				out.println("\t\tresponse.setStatus(javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR, \"JSP run-time error\");");
				out.println("\t\tresponse.setContentType(\"text/html\");");
				out.println("\t\tjava.io.PrintWriter errOut = response.getWriter();");
				out.println("\t\terrOut.println(\"<HTML><HEAD><TITLE>\" + javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR + \" JSP run-time error</TITLE></HEAD><BODY>\" +");
				out.println("\t\t\t\"<H2>\" + javax.servlet.http.HttpServletResponse.SC_INTERNAL_SERVER_ERROR + \" JSP run-time error</H2>\" +");
				out.println("\t\t\t\"The JSP page you requested could not be served because the following error(s) occured:<BR><PRE>\");");
				out.println("\t\terrOut.println(msg);");
				out.println("\t\terrOut.println(\"</PRE></BODY></HTML>\");");
				out.println("\t\terrOut.close();");
				out.println("\t}");
				out.println();

				out.println("\tprivate boolean __beanSetProperty(java.lang.Object bean, java.beans.PropertyDescriptor[] pds, java.lang.String key, java.lang.String value) {");
				out.println("\t\tjava.lang.reflect.Method meth;");
				out.println("\t\tfor(int i = 0; i < pds.length; i++) {");
				out.println("\t\t\tif(pds[i].getName().equals(key) && !pds[i].isHidden()) {");
				out.println("\t\t\t\tmeth = pds[i].getWriteMethod();");
				out.println("\t\t\t\tif(meth != null) {");
				out.println("\t\t\t\t\ttry {");
				out.println("\t\t\t\t\t\tmeth.invoke(bean, new Object[]{value});");
				out.println("\t\t\t\t\t\treturn true;");
				out.println("\t\t\t\t\t} catch(java.lang.IllegalAccessException iaccexc) {");
				out.println("\t\t\t\t\t\treturn false;");
				out.println("\t\t\t\t\t} catch(java.lang.IllegalArgumentException iargexc) {");
				out.println("\t\t\t\t\t\treturn false;");
				out.println("\t\t\t\t\t} catch(java.lang.reflect.InvocationTargetException itexc) {");
				out.println("\t\t\t\t\t\treturn false;");
				out.println("\t\t\t\t\t}");
				out.println("\t\t\t\t}");
				out.println("\t\t\t}");
				out.println("\t\t}");
				out.println("\t\treturn false;");
				out.println("\t}");
				out.println();

				out.println("\tprivate void __beanIntrospect(java.lang.Object bean, java.beans.PropertyDescriptor[] pds, javax.servlet.http.HttpServletRequest request) {");
				out.println("\t\tjava.lang.reflect.Method meth;");
				out.println("\t\tjava.lang.String value;");
				out.println("\t\tfor(int i = 0; i < pds.length; i++) {");
				out.println("\t\t\tif(!pds[i].isHidden()) {");
				out.println("\t\t\t\tvalue = request.getParameter(pds[i].getName());");
				out.println("\t\t\t\tif(value != null) {");
				out.println("\t\t\t\t\tmeth = pds[i].getWriteMethod();");
				out.println("\t\t\t\t\tif(meth != null) {");
				out.println("\t\t\t\t\t\ttry {");
				out.println("\t\t\t\t\t\t\tmeth.invoke(bean, new Object[]{value});");
				out.println("\t\t\t\t\t\t} catch(java.lang.IllegalAccessException iaccexc) {");
				out.println("\t\t\t\t\t\t\t//");
				out.println("\t\t\t\t\t\t} catch(java.lang.IllegalArgumentException iargexc) {");
				out.println("\t\t\t\t\t\t\t//");
				out.println("\t\t\t\t\t\t} catch(java.lang.reflect.InvocationTargetException itexc) {");
				out.println("\t\t\t\t\t\t\t//");
				out.println("\t\t\t\t\t\t}");
				out.println("\t\t\t\t\t}");
				out.println("\t\t\t\t}");
				out.println("\t\t\t}");
				out.println("\t\t}");
				out.println("\t}");
				out.println();

				// generate dependency check code
				out.println("\tpublic static final int __compilerVersionNr = " + COMPILER_VERSION_NR + ";");
				out.println();

				out.println("\tprivate static java.lang.Object[] __dependencies = new java.lang.Object[]{");
				e = dependencies.elements();
				for(;;) {
					f = (File) e.nextElement();
					l = (Long) e.nextElement();
					out.println("\t\tnew java.io.File(\"" + javaStringEncode(f.toString()) + "\"),");
					out.print("\t\tnew java.lang.Long(" + l + "L)");
					if(e.hasMoreElements()) {
						out.println(",");
					} else {
						out.println();
						break;
					}
				}
				out.println("\t};");
				out.println();

				out.println("\tpublic static boolean __checkDependencies() {");
				out.println("\t\tfor(int i = 0; i < __dependencies.length; i += 2) {");
				out.println("\t\t\tif(!((java.io.File) __dependencies[i]).exists() ||");
				out.println("\t\t\t\t\t((java.io.File) __dependencies[i]).lastModified() > ((java.lang.Long) __dependencies[i+1]).longValue()) {");
				out.println("\t\t\t\treturn true;");
				out.println("\t\t\t}");
				out.println("\t\t}");
				out.println("\t\treturn false;");
				out.println("\t}");

				// generate end of class
				out.println("}");
			} finally {
				out.close();
			}
		} catch(IOException ioexc) {
			throw new JSPException("Could not write java file " + javaFile + ": " + ioexc.getMessage());
		}
	}

	private void compileJavaFile() throws JSPException {
		String[]				compilerArgs;
		ByteArrayOutputStream	compilerOut;
		PrintStream				compilerOutStream;
		String					s, t;
		StringBuffer			buf;
		int						i, j, k, l;

		compilerOut = new ByteArrayOutputStream();
		compilerOutStream = new PrintStream(compilerOut, true);

		// build compiler command line
		if(jspServlet.compiler[0].equals("builtin-javac")) {
			compilerArgs = new String[jspServlet.compiler.length-1];
			j = 0;
		} else {
			compilerArgs = new String[jspServlet.compiler.length];
			compilerArgs[0] = jspServlet.compiler[0];
			j = 1;
		}
		compilerOutStream.print(jspServlet.compiler[0]);

		for(i = 1; i < jspServlet.compiler.length; i++) {
			s = jspServlet.compiler[i];
			buf = new StringBuffer(s.length() + 16);
			k = s.indexOf('%');
			l = -1;
			while(k != -1) {
				buf.append(s.substring(l+1, k));
				l = s.indexOf('%', k+1);
				if(l == -1) {
					l = k-1;
					break;
				} else {
					t = s.substring(k+1, l);
					if(t.length() == 0) {
						t = "%";
					} else if(t.equalsIgnoreCase("classpath")) {
						t = Utils.calculateClassPath(getClass().getClassLoader());
					} else if(t.equalsIgnoreCase("repository")) {
						t = jspServlet.repository.toString();
					} else if(t.equalsIgnoreCase("source")) {
						t = javaFile.toString();
					} else {
						t = jspServlet.getServletConfig().getInitParameter(t);
					}

					if(t != null) {
						buf.append(t);
					}
					k = s.indexOf('%', l+1);
				}
			}
			buf.append(s.substring(l+1));
			compilerArgs[j] = buf.toString();
			compilerOutStream.print((char) ' ');
			compilerOutStream.print(compilerArgs[j]);
			j++;
		}
		compilerOutStream.println();

		if(jspServlet.compiler[0].equals("builtin-javac")) {
			// use builtin compiler			try {
				Object javaCompiler = Class.forName("sun.tools.javac.Main").getConstructor(new Class[] {OutputStream.class, String.class}).newInstance(new Object[]{compilerOutStream, "javac"});
				if(Boolean.FALSE.equals(javaCompiler.getClass().getMethod("compile", new Class[]{String[].class}).invoke (javaCompiler, new Object[] {compilerArgs}))) {
					throw new JSPException(transcribeErrors(htmlEncode(compilerOut.toString())));
				}			} catch(Exception e) {				if (e instanceof JSPException)					throw (JSPException)e;
				throw new JSPException(transcribeErrors(htmlEncode("Can't instantiate Java compiler, "+e+"/"+e.getCause())));			}
		} else {
			// use external compiler
			Process			p;
			BufferedReader	stdout = null,
							stderr = null;
			String			line;
			int				exitValue = -1;
			long			classLastModified;

			classLastModified = classFile.lastModified();

			try {
				p = Runtime.getRuntime().exec(compilerArgs);
				stdout = new BufferedReader(new InputStreamReader(p.getInputStream()));
				stderr = new BufferedReader(new InputStreamReader(p.getErrorStream()));
				// polling should be threaded
				while((line = stdout.readLine()) != null) {
					compilerOutStream.println(line);
				}

				while((line = stderr.readLine()) != null) {
					compilerOutStream.println(line);
				}

				try {
					p.waitFor();
					exitValue = p.exitValue();
				} catch(InterruptedException ix) {
					;
				}
			} catch(IOException ioexc) {
				ioexc.printStackTrace(compilerOutStream);
			}

			if(classFile.lastModified() == classLastModified) {
				compilerOutStream.println("[no class file has been written]");
				exitValue = -1;
			}

			if(exitValue != 0) {
				throw new JSPException(transcribeErrors(htmlEncode(compilerOut.toString())));
			}
		}
	}
	
	private static String htmlEncode(String val) {
		StringBuffer	buf = new StringBuffer(val.length() + 8);
		char			c;

		for(int i = 0; i < val.length(); i++) {
			c = val.charAt(i);
			switch(c) {
			case '<':
				buf.append("&lt;");
				break;
			case '>':
				buf.append("&gt;");
				break;
			case '&':
				buf.append("&amp;");
				break;
			default:
				buf.append(c);
				break;
			}
		}
		return buf.toString();
	}

	private static class MapEntry {
		int			javaLineNr;
		String		jspFile;
		int			jspLineNr;

		MapEntry(int javaLineNr, String jspFile, int jspLineNr) {
			this.javaLineNr = javaLineNr;
			this.jspFile = jspFile;
			this.jspLineNr = jspLineNr;
		}
	}

	/**
	 * Transcribe error messages
	 */
	private String transcribeErrors(String errors) {
		LineNumberReader	in;
		BufferedReader		in2;
		Vector				map;
		Enumeration			e;
		MapEntry			entry;
		StringBuffer		errBuf;
		String				s, jspFile;
		int					i, j, k, l, javaLineNr, jspLineNr;

		try {
			/* Build mapping from java line numbers to jsp file/line# combinations.
			 * We could have done this will writing the java file, but using
			 * LineNumberReader is easier, and it would take extra time when
			 * no errors occur.
			 */
			in = new LineNumberReader(new FileReader(javaFile));
			in.setLineNumber(1);
			map = new Vector();
			try {
				while((s = in.readLine()) != null) {
					if(s.startsWith("//line ")) {
						i = s.indexOf(':');
						if(i >= 0) {
							try {
								map.addElement(new MapEntry(in.getLineNumber(),
									s.substring(7, i), Integer.parseInt(s.substring(i+1))));
							} catch(NumberFormatException nfexc) { }
						}
					}
				}
			} finally {
				in.close();
			}

			/* Now we read every line of the error messages and translate any
			 * file references there.
			 */
			in2 = new BufferedReader(new StringReader(errors));
			errBuf = new StringBuffer();
			try {
				while((s = in2.readLine()) != null) {
					i = s.indexOf(javaFile.getPath());
					if(i != -1) {
						j = i + javaFile.getPath().length();
						if(j < s.length()-1 && s.charAt(j) == ':' && Character.isDigit(s.charAt(j+1))) {
							j++;
							k = j;
							while(k < s.length() && Character.isDigit(s.charAt(k))) {
								k++;
							}
							l = k;
							while(l+1 < s.length() && s.charAt(l) == ':' && Character.isDigit(s.charAt(l+1))) {
								l += 2;
								while(l < s.length() && Character.isDigit(s.charAt(l))) {
									l++;
								}
							}

							try {
								javaLineNr = Integer.parseInt(s.substring(j, k));
								jspFile = null;
								jspLineNr = 0;
								for(e = map.elements(); e.hasMoreElements(); ) {
									entry = (MapEntry) e.nextElement();
									if(entry.javaLineNr > javaLineNr) {
										break;
									}
									jspFile = entry.jspFile;
									jspLineNr = entry.jspLineNr + (javaLineNr - entry.javaLineNr);
								}
								// valid translation found: use it
								if(jspFile != null) {
									errBuf.append(s.substring(0, i));
									errBuf.append("<B>").append(jspFile).append((char) ':').append(jspLineNr).append("</B>");
									errBuf.append("<!-- ").append(s.substring(i, l)).append(" -->");
									errBuf.append(s.substring(l)).append(lineSeparator);
									continue;
								}
							} catch(NumberFormatException nfexc2) { }
						}
					}
					errBuf.append(s).append(lineSeparator);
				}
				return errBuf.toString();
			} finally {
				in2.close();
			}
		} catch(IOException ioexc) {
			return errors;
		}
	}

	private static String javaStringEncode(String val) {
		StringBuffer	res;
		String			s;
		int				i;
		char			c;

		res = new StringBuffer(val.length());
		for(i = 0; i < val.length(); i++) {
			c = val.charAt(i);
			switch(c) {
			case '\n':
				res.append("\\n");
				break;
			case '\r':
				res.append("\\r");
				break;
			case '\'':
				res.append("\\\'");
				break;
			case '\"':
				res.append("\\\"");
				break;
			case '\\':
				res.append("\\\\");
				break;
			default:
				if(c > 0xFF) {
					s = "00" + Integer.toHexString(c);
					res.append("\\u").append(s.substring(s.length() - 4));
				} else if(c < ' ' || c >= 0x7F) {
					s = "00" + Integer.toOctalString(c);
					res.append((char) '\\').append(s.substring(s.length() - 3));
				} else {
					res.append((char) c);
				}
				break;
			}
		}
		return res.toString();
	}

	public static String getClassNameForJspFile(File jspFile) throws JSPException {
		StringTokenizer		toker;
		StringBuffer		buf;
		String				s = jspFile.toString();
		char				c;
		int					i;

		toker = new StringTokenizer(s, String.valueOf(File.separatorChar));
		buf = new StringBuffer(s.length() + 32);
		buf.append("_jsp");
		while(toker.hasMoreTokens()) {
			s = toker.nextToken();
			buf.append("._");
			for(i = 0; i < s.length(); i++) {
				c = s.charAt(i);
				if(Character.isJavaIdentifierPart(c)) {
					buf.append((char) c);
				} else {
					buf.append((char) '_').append(Integer.toHexString(c));
				}
			}
		}

		return buf.toString();
	}

	public static File getFileForClass(File repository, String className, String suffix) {
		return new File(repository, className.replace('.', File.separatorChar) + suffix);
	}
}
