/* tjws - SysTrayControl.java
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
 *  $Id: SysTrayControl.java,v 1.10 2009/12/31 05:02:13 dmitriy Exp $                
 *  Created on Jul 2, 2006
 *  @author Dmitriy
 */
package rogatkin.web;

import java.awt.AWTException;
import java.awt.Desktop;
import java.awt.MenuItem;
import java.awt.PopupMenu;
import java.awt.SplashScreen;
import java.awt.SystemTray;
import java.awt.Toolkit;
import java.awt.TrayIcon;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Arrays;
import java.util.Timer;
import java.util.TimerTask;
import java.util.ResourceBundle;
import java.util.MissingResourceException;

import rogatkin.web.WebApp.ServiceController;
import Acme.Serve.Serve;

public class SysTrayControl implements ServiceController, ActionListener {

	private Method s;

	private TrayIcon ti;

	private String port = "" + Serve.DEF_PORT;

	private ResourceBundle resource;

	public SysTrayControl() {
		try {
			resource = ResourceBundle.getBundle("rogatkin/resource/systraymenu");
		} catch (NullPointerException npe) {
		} catch (MissingResourceException mre) {
		}
	}

	public void attachServe(Method stop, String[] contextPath) {
		s = stop;
		if (SystemTray.isSupported() == false)
			return;
		SystemTray st = SystemTray.getSystemTray();
		PopupMenu popup = new PopupMenu();
		popup.setFont(new Font("Arial", Font.PLAIN, 12));
		//System.err.printf("%s%n", Arrays.toString(java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment() .getAvailableFontFamilyNames()));
		MenuItem mi;
		if (Desktop.isDesktopSupported()) {
			for (String cp : contextPath) {
				popup.add(mi = new MenuItem(getResource("label_open") + cp));
				mi.setActionCommand("!" + cp);
				mi.addActionListener(this);
			}
		}
		popup.addSeparator(); 
		popup.add(mi = new MenuItem(getResource("label_stop")));
		mi.setActionCommand("stop");
		mi.addActionListener(this);
		popup.add(mi = new MenuItem(getResource("label_exit")));
		mi.setActionCommand("exit");
		mi.addActionListener(this);
		//java.net.URL u;
		// TODO icon can be customizable
		ti = new TrayIcon(Toolkit.getDefaultToolkit().getImage(
				getClass().getClassLoader().getResource("rogatkin/resource/tjws.gif")), "TJWS"+getResource("title_control_panel"), popup);
		//javax.swing.JOptionPane.showMessageDialog(null, String.format("Created sys tray icon with image%s%n",u));
		ti.setImageAutoSize(true);

		try {
			st.add(ti);
		} catch (AWTException e) {

		}
		new Timer("Splash closer", true).schedule(new TimerTask() {
			@Override
			public void run() {
				SplashScreen ss = SplashScreen.getSplashScreen();
				if (ss != null)
					ss.close();
			}
		}, 3 * 1000);
	}

	public String[] massageSettings(String[] args) {
		boolean nohup = false;
		boolean nextPort = false;
		for (String arg : args)
			if ("-nohup".equals(arg)) {
				nohup = true;
			} else if ("-p".equals(arg))
				nextPort = true;
			else if (nextPort) {
				port = arg;
				nextPort = false;
			}

		if (SystemTray.isSupported()) {
			if (nohup == false) {
				args = Arrays.copyOf(args, args.length + 1);
				args[args.length - 1] = "-nohup";
			}
		} else {
			// remove '-nohup'

		}
		return args;
	}

	public void actionPerformed(ActionEvent event) {
		String cmd = event.getActionCommand();
		try {
			if ("stop".equals(cmd)) {
				ti.displayMessage("TJWS", getResource("label_stopping"), TrayIcon.MessageType.INFO);
				s.invoke(null); // TODO suspend it
			} else if ("exit".equals(cmd)) {
				s.invoke(null);
				System.exit(0);
			} else if (cmd.startsWith("!")) {
				//javax.swing.JOptionPane.showMessageDialog(null, String.format("http://localhost:%s/%s", port, contextPath));
				ti.displayMessage("TJWS", getResource("label_opening") + cmd.substring(1), TrayIcon.MessageType.INFO);
				Desktop desktop = Desktop.getDesktop();
				// TODO obtain host name, like inetaddress
				desktop.browse(new URI(String.format("http://%s:%s/%s", "localhost", port, cmd.substring(1))));
			} //else
			//javax.swing.JOptionPane.showMessageDialog(null, "Command "+event.getActionCommand());
		} catch (URISyntaxException e) {
			//e.printStackTrace();
		} catch (IOException e) {
			//e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
	}

	private String getResource(String key) {
		try {
			return resource.getString(key);
		} catch (NullPointerException npe) {
		} catch (MissingResourceException mre) {
		}
		return key;
	}
}
