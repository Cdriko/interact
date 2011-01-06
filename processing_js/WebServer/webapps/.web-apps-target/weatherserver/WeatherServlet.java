package org.developerworks.comet;

import com.sun.syndication.feed.synd.SyndEntry;
import com.sun.syndication.feed.synd.SyndFeed;
import com.sun.syndication.io.SyndFeedInput;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.AsyncContext;
import javax.servlet.ServletException;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(asyncSupported=true)
public class WeatherServlet extends HttpServlet {
   private MessageSender messageSender;
   private Weatherman weatherman ;
    @Override
    public void destroy() {
        messageSender.stop();
        messageSender = null;

    }

    @Override
    public void init() throws ServletException {
        messageSender = new MessageSender();
        Thread messageSenderThread =
                new Thread(messageSender, "MessageSender[" + getServletContext().getContextPath() + "]");
        messageSenderThread.setDaemon(true);
        messageSenderThread.start();

    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
        AsyncContext async = request.startAsync(request, response);
        messageSender.setConnection(async);
        if (weatherman == null)
        	async.start(weatherman  = new Weatherman(32444, 94303, 94538));
    }


private class Weatherman implements Runnable{

    private final List<URL> zipCodes;
    private final String YAHOO_WEATHER = "http://weather.yahooapis.com/forecastrss?p=";

    public Weatherman(Integer... zips) {
        zipCodes = new ArrayList<URL>(zips.length);
        for (Integer zip : zips) {
            try {
                zipCodes.add(new URL(YAHOO_WEATHER + zip));
            } catch (Exception e) {
                // dont add it if it sucks
            }
        }
    }

   public void run() {
       int i = 0;
       while (i >= 0) {
           int j = i % zipCodes.size();
           SyndFeedInput input = new SyndFeedInput();
           try {
               SyndFeed feed = input.build(new InputStreamReader(zipCodes.get(j).openStream()));
               SyndEntry entry = (SyndEntry) feed.getEntries().get(0);
               messageSender.send(entryToHtml(entry));
               Thread.sleep(30000L);
           } catch (Exception e) {
               // just eat it, eat it
           }
           i++;
       }
   }

    private String entryToHtml(SyndEntry entry){
        StringBuilder html = new StringBuilder("<h2>");
        html.append(entry.getTitle());
        html.append("</h2>");
        html.append(entry.getDescription().getValue());
        return html.toString();
    }
}

   private class MessageSender implements Runnable {

        protected boolean running = true;
        protected final ArrayList<String> messages = new ArrayList<String>();
        private AsyncContext connection;

		// This was changed to accept the Servlet 3.0 type AsyncContext
        private synchronized void setConnection(AsyncContext connection){
            this.connection = connection;
            notify();
        }

        public void stop() {
            running = false;
        }

        /**
         * Add message for sending.
         */
        public void send(String message) {
            synchronized (messages) {
                messages.add(message);
                log("Message added #messages=" + messages.size());
                messages.notify();
            }
        }

        public void run() {
            while (running) {
                if (messages.size() == 0) {
                    try {
                        synchronized (messages) {
                            messages.wait();
                        }
                    } catch (InterruptedException e) {
                        // Ignore
                    }
                }
                String[] pendingMessages = null;
                synchronized (messages) {
                    pendingMessages = messages.toArray(new String[0]);
                    messages.clear();
                }
                try {
                    if (connection == null){
                        try{
                            synchronized(this){
                                wait();
                            }
                        } catch (InterruptedException e){
                            // Ignore
                        }
                    }
                    PrintWriter writer = connection.getResponse().getWriter();
                    for (int j = 0; j < pendingMessages.length; j++) {
                        final String forecast = pendingMessages[j] + "<br>";
                        writer.println(forecast);
                        log("Writing:" + forecast);
                    }
                    writer.flush();
                    connection.complete();
                    connection = null;
                    log("Closing connection");
                } catch (IOException e) {
                    log("IOExeption sending message", e);
                }
            }
        }
    }
}
