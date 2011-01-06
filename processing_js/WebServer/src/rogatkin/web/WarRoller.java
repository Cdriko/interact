/* tjws - WarRoller.java
 * Copyright (C) 2004-2010 Dmitriy Rogatkin.  All rights reserved.
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
 *  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  $Id: WarRoller.java,v 1.13 2010/05/16 04:02:48 dmitriy Exp $
 * Created on Dec 13, 2004
 */
package rogatkin.web;

import java.io.File;
import java.io.FileFilter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipFile;
import java.util.ArrayList;
import java.util.Enumeration;

import javax.servlet.ServletException;

import Acme.Utils;
import Acme.Serve.Serve;
import Acme.Serve.WarDeployer;

public class WarRoller implements WarDeployer {

	public static final String DEPLOY_ARCH_EXT = ".war";

	public static final String DEPLOYMENT_DIR_TARGET = ".web-apps-target";

	public static final String DEF_DEPLOY_DYNAMICALLY = "tjws.wardeploy.dynamically";

	public static final String DEF_VIRTUAL = "tjws.virtual";

	/**
	 * in deploy mode scans for all wars in war directory (app deployment dir)
	 * for each war looks in corresponding place of deploy directory and figures a difference,
	 * like any file in war exists and no corresponding file in deploy directory or it's older if difference positive, then delete target deploy directory
	 * unpack war if run mode process all WEB-INF/web.xml and build app descriptor, including context name, servlet names, servlet urls, class parameters
	 * process every app descriptor as standard servlet connection proc dispatch for every context name assigned an app dispatcher, it uses the rest to find
	 * servlet and do resource mapping
	 * 
	 */

	public void deploy(File warDir, final File deployTarDir, final String virtualHost) {
		// by list
		if (warDir.listFiles(new FileFilter() {
			public boolean accept(File pathname) {
				if (pathname.isFile() && pathname.getName().toLowerCase().endsWith(DEPLOY_ARCH_EXT)) {
					deployWar(pathname, deployTarDir);
					return true;
				}
				return false;
			}
		}).length == 0)
			server.log("No .war packaged web apps found in "+(virtualHost==null?"default":virtualHost));
		if (deployTarDir.listFiles(new FileFilter() {
			public boolean accept(File file) {
				if (file.isDirectory())
					try {
						attachApp(WebAppServlet.create(file, file.getName(), server, virtualHost), virtualHost);
						return true;
					} catch (ServletException se) {
						server.log("Creation of a web app " + file.getName() + " failed due " + se.getRootCause(), se
								.getRootCause());
					}
				return false;
			}
		}).length == 0)
			server.log("No web apps have been deployed in "+(virtualHost==null?"default":virtualHost));
	}

	public void deployWar(File warFile, File deployTarDir) {
		String context = warFile.getName();
		assert context.toLowerCase().endsWith(DEPLOY_ARCH_EXT);
		context = context.substring(0, context.length() - DEPLOY_ARCH_EXT.length());
		server.log("Deploying " + context);
		ZipFile zipFile = null;
		File deployDir = new File(deployTarDir, context);
		try {
			// some overhead didn't check that doesn't exist
			if (assureDir(deployDir) == false) {
				server.log("Can't reach deployment dir " + deployDir);
				return;
			}
			zipFile = new ZipFile(warFile);
			Enumeration<? extends ZipEntry> entries = zipFile.entries();
			while (entries.hasMoreElements()) {
				ZipEntry ze = entries.nextElement();
				String en = ze.getName();
				if (File.separatorChar == '/')
					en = en.replace('\\', File.separatorChar);
				File outFile = new File(deployDir, en);
				if (ze.isDirectory()) {
					outFile.mkdirs();
				} else {
					OutputStream os = null;
					InputStream is = null;
					File parentFile = outFile.getParentFile();
					if (parentFile.exists() == false)
						parentFile.mkdirs();
					if (outFile.exists() && outFile.lastModified() >= ze.getTime()) {
						continue;
					}
					try {
						os = new FileOutputStream(outFile);
						is = zipFile.getInputStream(ze);
						copyStream(is, os);
						outFile.setLastModified(ze.getTime());
					} catch (IOException ioe2) {
						server.log("Problem in extracting " + en + " " + ioe2);
					} finally {
						try {
							os.close();
						} catch (Exception e2) {

						}
						try {
							is.close();
						} catch (Exception e2) {

						}
					}
				}
			}
		} catch (ZipException ze) {
			server.log("Invalid .war format");
		} catch (IOException ioe) {
			server.log("Can't read " + warFile + "/ " + ioe);
		} finally {
			try {
				zipFile.close();
			} catch (Exception e) {

			}
			zipFile = null;
		}
	}

	protected void attachApp(WebAppServlet appServlet, String virtualHost) {
		server.addServlet(appServlet.contextPath, appServlet, virtualHost);
	}

	public void deploy(Serve server) {
		this.server = server;
		String webapp_dir = System.getProperty(WebApp.DEF_WEBAPP_AUTODEPLOY_DIR);
		if (webapp_dir == null)
			webapp_dir = System.getProperty("user.dir") + File.separator + "webapps";
		final File file_webapp = new File(webapp_dir);
		if (assureDir(file_webapp) == false) {
			server.log("Deployment source location " + file_webapp + " isn't a directory, deployment is impossible.");
			return;
		}
		final File file_deployDir = new File(file_webapp, DEPLOYMENT_DIR_TARGET);
		if (assureDir(file_deployDir) == false) {
			server
					.log("Target deployment location " + file_deployDir
							+ " isn't a directory, deployment is impossible.");
			return;
		}
		deploy(file_webapp, file_deployDir, null);

		int td = 0;
		if (System.getProperty(DEF_DEPLOY_DYNAMICALLY) != null) {
			td = 20;
			try {
				td = Integer.parseInt(System.getProperty(DEF_DEPLOY_DYNAMICALLY));
			} catch (NumberFormatException nfe) {
				server.log("Default redeployment check interval: " + td + " is used");
			}
		}
		final int interval = td * 1000; 
		createWatcherThread(file_webapp, file_deployDir, interval, null);
		if (null != System.getProperty(DEF_VIRTUAL)) {
			file_webapp.listFiles(new FileFilter() {
				@Override
				public boolean accept(File pathname) {
					String virtualHost;
					if (pathname.isDirectory()
							&& (virtualHost = pathname.getName()).equals(DEPLOYMENT_DIR_TARGET) == false) {

						final File file_deployDir = new File(pathname, DEPLOYMENT_DIR_TARGET);
						if (assureDir(file_deployDir) == false) {
							WarRoller.this.server.log("Target deployment location " + file_deployDir
									+ " isn't a directory, deployment is impossible.");
						} else {
							deploy(pathname, file_deployDir, virtualHost);
							createWatcherThread(pathname, file_deployDir, interval, virtualHost);
							return true;
						}
					}
					return false;
				}
			});
		}
	}

	protected void createWatcherThread(final File file_webapp, final File file_deployDir, final int interval,
			final String virtualHost) {
		if (interval <= 0)
			return;
		Thread watcher = new Thread("Deploy update watcher for " + (virtualHost == null ? "main" : virtualHost)) {
			public void run() {
				for (;;)
					try {
						deployWatch(file_webapp, file_deployDir, virtualHost);
					} catch (Throwable t) {
						if (t instanceof ThreadDeath)
							throw (ThreadDeath) t;
						WarRoller.this.server.log("Unhandled " + t, t);
					} finally {
						try {
							Thread.sleep(interval);
						} catch (InterruptedException e) {
							break;
						}
					}
			}
		};
		watcher.setDaemon(true);
		watcher.start();
	}

	protected boolean assureDir(File fileDir) {
		if (fileDir.exists() == false)
			fileDir.mkdirs();
		if (fileDir.isDirectory() == false) {
			return false;
		}
		return true;
	}

	protected synchronized void deployWatch(File warDir, final File deployTarDir, String virtualHost) {
		server.setHost(virtualHost);
		Enumeration se = server.getServlets();
		ArrayList<WebAppServlet> markedServlets = new ArrayList<WebAppServlet>(10);
		while (se.hasMoreElements()) {
			Object servlet = se.nextElement();
			if (servlet instanceof WebAppServlet) {
				WebAppServlet was = (WebAppServlet) servlet;
				File war = new File(warDir, was.deployDir.getName() + DEPLOY_ARCH_EXT);
				if (war.exists() && war.lastModified() > was.lastDeployed) {
					// deployWar(new File(warDir, was.deployDir.getName() + DEPLOY_ARCH_EXT), deployTarDir);
					markedServlets.add(was);
				}
			}
		}
		// TODO add scan for newly added wars
		//if (markedServlets .size() > 0) 
		for (WebAppServlet was : markedServlets) {
			was = (WebAppServlet) server.unloadServlet(was);
			was.destroy();
			// TODO decide about sessions, like invalidate, or invalidate-store-load servlet-load
			// TODO use pre-saved war name
			deployWar(new File(warDir, was.deployDir.getName() + DEPLOY_ARCH_EXT), deployTarDir);
			try {
				was = WebAppServlet.create(was.deployDir, was.deployDir.getName(), server, virtualHost);
				attachApp(was, virtualHost);
			} catch (ServletException sex) {
				server.log("Creation of a web app " + was.contextName + " failed due " + sex.getRootCause(), sex
						.getRootCause());
			}
		}
	}

	static void copyStream(InputStream is, OutputStream os) throws IOException {
		Utils.copyStream(is, os, -1);
	}

	protected Serve server;
}