/* tjws - SimpleDataSource.java
 * Copyright (C) 1999-2010 Dmitriy Rogatkin.  All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
 *  
 *  Visit http://tjws.sourceforge.net to get the latest information
 *  about Rogatkin's products.                                                        
 *  $Id: SimpleDataSource.java,v 1.21 2010/07/12 22:40:40 dmitriy Exp $                
 *  Created on Mar 25, 2007
 *  @author Dmitriy
 */
package rogatkin.app;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Properties;
import java.util.concurrent.ArrayBlockingQueue;

import javax.naming.InitialContext;
import javax.sql.DataSource;
import javax.sql.RowSet;

/**
 * The class presents data source, which is created based on a property file
 * <p>
 * The following properties are allowed: <br>
 * <ul>
 * <li> <i>jndi-name</i> - under this name the data source will be registered
 * in JNDI if name starts with <strong>jdbc</strong>, then prefix
 * <i>java:comp/env/</i> will be added.
 * <li> <i>driver-class</i> - class name of JDBC driver
 * <li> <i>url</i> - JDBC connection URL
 * <li> <i>user</i> - connection user
 * <li> <i>password</i> - connection password
 * <li> <i>pool-size</i> - max number of allocated connections, 0 = no size
 * limitation, -1 = no pool used
 * <li> <i>access-timeout</i> - timeout in ms before getting an exception on
 * connection request when no connections are available, 0 means wait forever
 * <li> <i>driver-class-path</i> - defines class path to driver archive, unless
 * it is already in boot classpath
 * <li><i>prob-query</i> defines a query to verify that given connection is
 * valid, executed at time getting a connection from pool. If <strong>isValid</strong>
 * is specified as value, then isValid() method of SQL connection is used (note
 * that it is available only in Java 6 drivers). If <strong>isClosed</strong> is
 * specified, then isClosed() method used for a connection validation.
 * <li><i>exception-handler</i> - a name of class implementing static public
 * method boolean validate(SQLException, Connection). This class is used to verify if
 * SQLException indicates that the connection isn't valid anymore and has to be
 * removed from the pool. The method returns true, if the connection still good
 * for further use.
 * </ul>
 * 
 * @author dmitriy
 * 
 */
public class SimpleDataSource extends ObjectPool<Connection> implements DataSource {
	public final static String RW_NATIVE = "isValid";

	public final static String RW_ISCLOSED = "isClosed";

	protected final static int DEFAULT_CAPACITY = 20;

	protected Properties dataSourceProperties, conectionProperties;

	protected Driver driver;

	private int capacity;

	private PrintWriter logWriter;

	private Method connectionValidateMethod;

	private String validateQuery;

	public SimpleDataSource(String definitionPropertiesLocation) {
		super(new ArrayBlockingQueue<Connection>(DEFAULT_CAPACITY));
		logWriter = new PrintWriter(System.out);
		InputStream propertiesStream = null;
		File f = new File(definitionPropertiesLocation);
		try {
			if (f.exists())
				propertiesStream = new FileInputStream(f);
			else {
				propertiesStream = new URL(definitionPropertiesLocation).openStream();
			}
			dataSourceProperties = new Properties();
			if (definitionPropertiesLocation.toLowerCase().endsWith(".xml"))
				dataSourceProperties.loadFromXML(propertiesStream);
			else
				dataSourceProperties.load(propertiesStream);
			String classPath = dataSourceProperties.getProperty("driver-class-path");
			URLClassLoader classLoader = null;
			if (classPath == null) {
				Class.forName(dataSourceProperties.getProperty("driver-class"));
				driver = DriverManager.getDriver(dataSourceProperties.getProperty("url"));
			} else {
				String[] classPaths = classPath.split(File.pathSeparator);
				URL[] urls = new URL[classPaths.length];
				for (int i = 0; i < urls.length; i++)
					urls[i] = new URL("file:" + classPaths[i]);
				if (RW_NATIVE.equals(classPath))
					driver = (Driver) Class.forName(dataSourceProperties.getProperty("driver-class"), true,
							Thread.currentThread().getContextClassLoader()).newInstance();
				else
					driver = (Driver) Class.forName(dataSourceProperties.getProperty("driver-class"), true,
							classLoader = new URLClassLoader(urls, DriverManager.class.getClassLoader())).newInstance();
			}
			conectionProperties = new Properties();
			if (dataSourceProperties.getProperty("user") != null) {
				conectionProperties.setProperty("user", dataSourceProperties.getProperty("user"));
				if (dataSourceProperties.getProperty("password") != null)
					conectionProperties.setProperty("password", dataSourceProperties.getProperty("password"));
			}
			try {
				setTimeout(Integer.parseInt(dataSourceProperties.getProperty("access-timeout")));
			} catch (Exception e) {
			}
			try {
				capacity = Integer.parseInt(dataSourceProperties.getProperty("pool-size"));
				this.pool = new ArrayBlockingQueue<Connection>(capacity, true);
				this.borrowed = new ArrayList<Connection>(capacity);
			} catch (Exception e) {
				capacity = DEFAULT_CAPACITY;
			}
			validateQuery = dataSourceProperties.getProperty("prob-query");
			String conValClass = dataSourceProperties.getProperty("exception-handler");
			if (conValClass != null)
				connectionValidateMethod = (classLoader == null ? Class.forName(conValClass) : Class.forName(
						conValClass, true, classLoader)).getMethod("validate", SQLException.class, Connection.class);
			String jndiName = dataSourceProperties.getProperty("jndi-name");
			if (jndiName != null) {
				if (jndiName.startsWith("jdbc/"))
					jndiName = "java:comp/env/" + jndiName;
				new InitialContext().bind(jndiName, this);
			}
		} catch (FileNotFoundException e) {
			throw new IllegalArgumentException(e);
		} catch (MalformedURLException e) {
			throw new IllegalArgumentException(
					"Data source properties file doesn't exist, and can't be resolved as URL", e);
		} catch (NoSuchMethodException e) {
			throw new IllegalArgumentException("Connection validator class problem", e);
		} catch (Exception e) {
			throw new IllegalArgumentException(e);
		} finally {
			if (propertiesStream != null)
				try {
					propertiesStream.close();
				} catch (IOException e) {
				}
		}
	}

	public Connection getConnection() throws SQLException {
		Connection realConn = validateQuery == null?get():getValidated();
		return (Connection) Proxy.newProxyInstance(realConn.getClass().getClassLoader(), new Class[] {
			Connection.class, Wrapper }, new ConnectionWrapperHandler(realConn));
	}
	
	@Override
	public String toString() {
		Properties masked = (Properties) dataSourceProperties.clone();
		masked.setProperty("password", "*******");
		return "Pooled data source : "+masked+"\n"+ conectionProperties+"\n capacity:"+capacity+
		", available: "+pool.size()+", borrowed: "+borrowed.size();
	}

	private Connection getValidated() {
		boolean bad = true;
		do {
			Connection result = get();
			Statement statement = null;
			try {
				if (validateQuery.equals(RW_NATIVE))
					try {
						if ((Boolean) result.getClass().getMethod("isValid", int.class).invoke(10))
							return result;
						else
							;
					} catch (Exception e) {
						e.printStackTrace();
					}
				else if (validateQuery.equals(RW_ISCLOSED)) {
					if (result.isClosed() == false)
						return result;
				} else {
					// TODO it can be reasonable to execute the query in a
					// thread and join in millis
					// because dropped connection can hung a query
					statement = result.createStatement();
					statement.execute(validateQuery);
					return result;
				}
			} catch (SQLException e) {
				log("Discarding connection %s because %s%n", null, result, e);
			} finally {
				if (statement != null)
					try {
						statement.close();
					} catch (SQLException e) {
					}
			}
			remove(result);
		} while (bad);
		throw new IllegalStateException();
	}

	public Connection getConnection(String user, String password) throws SQLException {
		conectionProperties.setProperty("user", user);
		conectionProperties.setProperty("password", password);
		return getConnection();
	}

	public PrintWriter getLogWriter() throws SQLException {
		return logWriter;
	}

	public int getLoginTimeout() throws SQLException {
		return timeout;
	}

	public void setLogWriter(PrintWriter timeout) throws SQLException {
		logWriter = timeout;
	}

	public void setLoginTimeout(int timeout) throws SQLException {
		// not quite what it is
		setTimeout(timeout);
	}

	public boolean isWrapperFor(Class<?> cl) throws SQLException {
		return DataSource.class.equals(cl) || ObjectPool.class.equals(cl);
	}

	public <T> T unwrap(Class<T> arg0) throws SQLException {
		if (isWrapperFor(arg0))
			return (T) this;
		return null;
	}

	protected void log(String message, Throwable ex, Object... args) {
		if (args == null || args.length == 0)
			logWriter.write(message + "\n"); // ?? lineSeparator?
		else
			logWriter.write(String.format(message, args));
		if (ex != null)
			ex.printStackTrace(logWriter);
		logWriter.flush();
	}

	@Override
	protected void discard(Connection obj) {
		try {
			((Connection) obj.getClass().getMethod("unwrap", Class.class).invoke(obj, Connection.class)).close();
		} catch (Exception e) {
		}
	}

	@Override
	protected Connection create() {
		try {
			return driver.connect(dataSourceProperties.getProperty("url"), conectionProperties);
		} catch (SQLException e) {
			log("Can't create conection for %s%n", e, dataSourceProperties.getProperty("url"));
			throw new IllegalArgumentException("Can't create connection, check connection parameters and class path for JDBC driver", e);
		}
	}

	private Throwable processException(InvocationTargetException ite, Connection conn, Connection proxyConn)
			throws IllegalArgumentException, IllegalAccessException {
		if (connectionValidateMethod != null) {
			Throwable se = ite.getCause();
			//System.err.println("Cause*********"+se+" instance sql:"+(se instanceof SQLException));
			try {
				if (se instanceof SQLException && connectionValidateMethod.invoke(null, se, conn).equals(Boolean.FALSE)) 
					remove(conn);
			} catch (InvocationTargetException e) {
				
			}
			return se;
		}
		return ite.getCause();
	}

	@Override
	public int getCapacity() {
		return capacity;
	}

	class ConnectionWrapperHandler implements InvocationHandler {

		private Connection realConn;

		ConnectionWrapperHandler(Connection conn) {
			realConn = conn;
		}

		public Object invoke(final Object proxyConn, Method methd, Object[] params) throws Throwable {
			if (realConn == null)
				throw new SQLException("The connection is closed");
			if (methd.getName().equals("close")) {
				// log("Closing %s%n", null, proxyConn);
				if (realConn.getAutoCommit() == false)
					try {
						realConn.rollback();
					} catch (SQLException se) {

					}
				put(realConn);
				realConn = null;
			} else if (methd.getName().equals("unwrap")) // &&
				return realConn;
			else if (methd.getName().equals("isWrapperFor"))
				return ((Class) params[0]).isInstance(realConn);
			else if (methd.getName().equals("equals"))
				return proxyConn == params[0];
			else {
				try {
					final Object realStmt = methd.invoke(realConn, params);
					if (realStmt instanceof Statement == false)
						return realStmt;
					// wrap statement
					return Proxy.newProxyInstance(realStmt.getClass().getClassLoader(), new Class[] {
							CallableStatement.class, PreparedStatement.class, Statement.class, Wrapper },
							new InvocationHandler() {
								public Object invoke(final Object proxyStmt, Method methd, Object[] params)
										throws Throwable {
									if (methd.getName().equals("getConnection")) {
										return proxyConn;
									} else if (methd.getName().equals("unwrap"))
										return realStmt; // real statement
									else if (methd.getName().equals("isWrapperFor"))
										return ((Class) params[0]).isInstance(realStmt);
									try {
										final Object realRS = methd.invoke(realStmt, params);
										if (realRS instanceof ResultSet == false)
											return realRS;
										return Proxy.newProxyInstance(realRS.getClass().getClassLoader(), new Class[] {
												RowSet.class, ResultSet.class, Wrapper }, new InvocationHandler() {
											public Object invoke(final Object proxyRS, Method methd, Object[] params)
													throws Throwable {
												if (methd.getName().equals("getStatement")) {
													return proxyStmt;
												} else if (methd.getName().equals("unwrap"))
													return realRS; // resultset
												else if (methd.getName().equals("isWrapperFor"))
													return ((Class) params[0]).isInstance(realRS);
												try {
													return methd.invoke(realRS, params);
												} catch (InvocationTargetException ite) {
													throw processException(ite, realConn, (Connection) proxyConn);
												}
											}
										});
									} catch (InvocationTargetException ite) {
										throw processException(ite, realConn, (Connection) proxyConn);
									}
								}
							});
				} catch (InvocationTargetException ite) {
					throw processException(ite, realConn, (Connection) proxyConn);
				}
			}
			return null;
		}
	}

}
