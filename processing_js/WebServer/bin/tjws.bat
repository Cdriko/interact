cd ..
set JDK_HOME=C:\Program Files\Java\jdk1.6.0_20
set SERVLET_API=lib\servlet.jar
java -cp "%SERVLET_API%;lib\war.jar;lib\webserver.jar;lib\jsp.jar;lib\jspengine.jar;lib\gnujsp09.jar;%JDK_HOME%\lib\tools.jar" -Dtjws.webappdir=webapps -Dtjws.wardeploy.warname-as-context=yes Acme.Serve.Main -a aliases.properties -p 80 -l -c cgi-bin -j gnu.jspengine.JspServlet -gnu.jspengine.JspServlet.scratchdir %%deploydir%%/~~~/_jsp -gnu.jspengine.JspServlet.classloadername %%classloader%%
