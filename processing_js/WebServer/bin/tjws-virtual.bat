cd ..
set JDK_HOME=C:\Program Files\Java\jdk1.6.0_18
java -Xmx700m -cp "lib\servlet.jar;lib\war.jar;lib\webserver.jar;lib\jsp.jar;lib\jspengine.jar;lib\gnujsp09.jar;%JDK_HOME%\lib\tools.jar" -Dtjws.webappdir=webapps -Dtjws.wardeploy.warname-as-context=yes -Dtjws.virtual -Dtjws.wardeploy.as-root.dt-dmitriy-d620=addressbook -Dtjws.wardeploy.as-root.localhost=sqlfair Acme.Serve.Main -a aliases.properties -p 80 -l -c cgi-bin -j gnu.jspengine.JspServlet -gnu.jspengine.JspServlet.scratchdir %%deploydir%%/~~~/_jsp -gnu.jspengine.JspServlet.classloadername %%classloader%%
