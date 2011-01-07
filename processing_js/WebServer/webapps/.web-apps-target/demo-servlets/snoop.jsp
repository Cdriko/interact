<html>
<!-- Copyright (c) 1999-2000 by BEA Systems, Inc. All Rights Reserved.

  $Id: snoop.jsp,v 1.9 2008/02/27 02:34:50 dmitriy Exp $
  This JSP is packaged with Rogatkin's for demonstration purpose
  -->
<head>
<title>Snoop Servlet</title>
</head>
<%@ page import = "java.util.Enumeration" %>
<%@ page import = "javax.servlet.http.HttpUtils" %>
<body bgcolor=#FFFFFF>
<font face="Helvetica">
<h2>
<font color=#DB1260>
Snoop Servlet
</font>
</h2>

<p>
This servlet returns information about the HTTP request
itself. You can modify this servlet to take this information
and store it elsewhere for your HTTP server records. This
servlet is also useful for debugging.

<h3>
Requested URL
</h3>

<pre>
<%= HttpUtils.getRequestURL(request) %>
</pre>

<h3>
Init parameters
</h3>

<pre>
<%
Enumeration e = getServletConfig().getInitParameterNames();
while (e.hasMoreElements()) {
  String name = (String)e.nextElement();
  out.println(name + ": " + getInitParameter(name));
}
%>
</pre>

<h3>
Request information
</h3>

<pre>
Request Method: <%= request.getMethod() %>
Request URI: <%= request.getRequestURI() %>
Request Protocol: <%= request.getProtocol() %>
Servlet Path: <%= request.getServletPath() %>
Path Info: <%= request.getPathInfo() %>
Path Translated: <%= request.getPathTranslated() %>
Query String: <%= request.getQueryString() %>
Content Length: <%= request.getContentLength() %>
Content Type: <%= request.getContentType() %>
Server Name: <%= request.getServerName() %>
Server Port: <%= request.getServerPort() %>
Remote User: <%= request.getRemoteUser() %>
Remote Address: <%= request.getRemoteAddr() %>
Remote Host: <%= request.getRemoteHost() %>
Authorization Scheme: <%= request.getAuthType() %>
Secure: <%= request.isSecure()?"TRUE":"FALSE" %>
<% 
  if (request.isSecure()) {
     out.println("Cipher: "+request.getAttribute("javax.servlet.request.cipher_suite"));
     out.println("Key bits: "+request.getAttribute("javax.servlet.request.key_size"));
     out.println("SSL cipher suite : "+request.getAttribute("javax.net.ssl.cipher_suite"));
     out.println("The chain of X.509 certificates  : "+request.getAttribute("javax.net.ssl.peer_certificates"));
     out.println("An SSL session object : "+request.getAttribute("javax.net.ssl.session"));
  }
%>
</pre>

<h3>
Request headers
</h3>

<pre>
<%
e = request.getHeaderNames();
while (e.hasMoreElements()) {
  String name = (String)e.nextElement();
  out.println(name + ": " + request.getHeader(name));
}
%>
</pre>

<h3>
Request attributes
</h3>

<pre>
<%
e = request.getAttributeNames();
while (e.hasMoreElements()) {
  String name = (String)e.nextElement();
  out.println(name + ": " + request.getAttribute(name));
}
%>
</pre>

<p>
<font size=-1>Copyright &copy; 1999-2000 by BEA Systems, Inc. All Rights Reserved.
<br>Copyright &copy; 1999-2007 by Dmitriy Rogatkin. All Rights Reserved.
</font>

</font>
</body>
</html>