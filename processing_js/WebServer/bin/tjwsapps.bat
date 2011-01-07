echo off
cd ..
set JDK_HOME=C:\Program Files\Java\jdk1.6.0_04
echo STOP!!! this configuration uses dounle head acceptor, so read security section first to setup keystore 
echo and provide correct keystore password
pause
java -cp "lib\servlet.jar;lib\war.jar;lib\webserver.jar;lib\app.jar;lib\jsp.jar;lib\jspengine.jar;lib\gnujsp09.jar;%JDK_HOME%\lib\tools.jar" -Dtjws.webappdir=webapps rogatkin.app.Main -a aliases.properties -p 80 -l -c cgi-bin -acceptorImpl rogatkin.web.DualSocketAcceptor -ssl-port 443 -keystorePass 123456 -dataSource mediachest_ds.properties -j gnu.jspengine.JspServlet -gnu.jspengine.JspServlet.scratchdir %%deploydir%%/~~~/_jsp -gnu.jspengine.JspServlet.classloadername %%classloader%%
