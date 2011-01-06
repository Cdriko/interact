/*
	
	p5_sc: A SuperCollider library for Processing.org
	
	Copyright (c) 2007 Daniel Jones. All rights reserved.

	http://www.erase.net/
	
	----------------------------------------------------------------------

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
	
*/

package supercollider;

import oscP5.*;
import netP5.*;

public class SCBuffer
{
	public SCServer server;
	public int   index = -1,
	             frames,
	             channels;
	public float sampleRate;
	
	String path;
	
	int getm_count = 0,
	    getm_remaining = 0;

	float [] getm_buffer;
	Object getm_target;
	String getm_action;

	public SCBuffer()
	{
		this(SCServer.local, 1);
	}
	
	public SCBuffer (SCServer server, int channels)
	{
		this(server, 0, 2);
	}

	public SCBuffer (int frames, int channels)
	{
		this(SCServer.local, frames, channels);
	}
	
	public SCBuffer (int channels)
	{
		this(SCServer.local, 0, channels);
	}
	
	public SCBuffer (SCServer server, int frames, int channels)
	{
		this.server	= server;
		this.frames	= frames;
		this.channels	= channels;
		
		index = server.allocator_buffer.alloc(channels);
		
		server.buffers[index] = this;
//		if (index > -1)
//			trace("Allocated buffer: (" + index + ", " + channels + "c)");
//		else
//			warn("ALLOC FAILED!");
	}
	
	public void read(String path)
	{
		this.read(path, null, null);
	}
	
	public void read(String path, Object target, String action)
	{
		this.path = path;
		
		OscMessage msg = new OscMessage("/b_allocRead");
		msg.add(index);
		msg.add(path);
		
		if (target != null)
		{
			msg.add(0);
			msg.add(0);
		
			OscMessage action_msg = new OscMessage("/b_query");
			action_msg.add(index);
			msg.add(action_msg.getBytes());
		
			server.add_responder_b_info(index, target, action);
		}
		
		SCServer.osc.send(msg, server.addr);
	}
	
	public void query()
	{
		OscMessage msg = new OscMessage("/b_query");
		msg.add(index);
		SCServer.osc.send(msg, server.addr);
	}
	
	
	public void alloc()
	{
		this.alloc(null, null);
	}
	
	public void alloc(Object target, String action)
	{
		OscMessage msg = new OscMessage("/b_alloc");
		msg.add(index);
		msg.add(frames);
		msg.add(channels);
		
		if (target != null)
		{
			OscMessage action_msg = new OscMessage("/b_query");
			action_msg.add(index);
			msg.add(action_msg.getBytes());
		
			server.add_responder_b_info(index, target, action);
		}
		
		SCServer.osc.send(msg, server.addr);
	}
	
	public void write(String path, String type, String format, int frames, int start, int leave_open)
	{
		this.write(path, type, format, frames, start, leave_open, null, null);
	}

	
	public void write(String path, String type, String format, Object target, String action)
	{
		this.write(path, type, format, -1, 0, 0, target, action);
	}
	
	public void write(String path, String type, String format)
	{
		this.write(path, type, format, -1, 0, 0, null, null);
	}

	public void write(String path, String type, String format, int frames, int start, int leave_open, Object target, String action)
	{
		this.path = path;
		
		OscMessage msg = new OscMessage("/b_write");
		msg.add(index);
		msg.add(path);
		msg.add(type);
		msg.add(format);
		msg.add(frames);
		msg.add(start);
		msg.add(leave_open);
		
		if (target != null)
		{
			OscMessage action_msg = new OscMessage("/b_query");
			action_msg.add(index);
			msg.add(action_msg.getBytes());
		
			server.add_responder_b_info(index, target, action);			
		}
		
		SCServer.osc.send(msg, server.addr);
	}
	
	public void close ()
	{
		this.close(null, null);
	}
	
	public void close(Object target, String action)
	{
		OscMessage msg = new OscMessage("/b_close");
		msg.add(index);
		
		if (target != null)
		{
			OscMessage action_msg = new OscMessage("/b_query");
			action_msg.add(index);
			msg.add(action_msg.getBytes());
		
			server.add_responder_b_info(index, target, action);
		}		
		
		SCServer.osc.send(msg, server.addr);
	}
	

	
	public void free()
	{
		this.free(null, null);
	}

	public void free(Object target, String action)
	{
		if (index < -1)
			return;
			
		OscMessage msg = new OscMessage("/b_free");
		msg.add(index);

		if (target != null)
		{
			OscMessage action_msg = new OscMessage("/b_query");
			action_msg.add(index);
			msg.add(action_msg.getBytes());
		
			server.add_responder_b_info(index, target, action);
		}
		
		SCServer.osc.send(msg, server.addr);
		server.allocator_buffer.free(index);
	}
	
	public void get(int frame, Object target, String action)
	{
		OscMessage msg = new OscMessage("/b_get");
		msg.add(index);
		msg.add(frame);
		SCServer.osc.send(msg, server.addr);
		
		server.add_responder_b_set(index, frame, target, action);
	}
	
	public void get(int[] frames, Object target, String action)
	{
		OscMessage msg = new OscMessage("/b_get");
		
		msg.add(index);
		for (int i = 0; i < frames.length; i++)
			msg.add(frames[i]);
			
		SCServer.osc.send(msg, server.addr);
		
		server.add_responder_b_set(index, frames, target, action);	
	}
	
	public void getn(int frame, int count, Object target, String action)
	{
		OscMessage msg = new OscMessage("/b_getn");
		msg.add(index);
		msg.add(frame);
		msg.add(count);
		SCServer.osc.send(msg, server.addr);
		
		server.add_responder_b_setn(index, target, action);
	}
	
	public void getm(int frame, int count, Object target, String action)
	{
		int blocks = 1 + ((count - 1) / 256);
		getm_count = count;
		getm_buffer = new float[count];
		getm_remaining = blocks;
		getm_target = target;
		getm_action = action;

		for (int i = 0; i < blocks; i++)
		{
			OscMessage msg = new OscMessage("/b_getn");
			msg.add(index);
			msg.add(i * 256);
			if (i < blocks - 1)
				msg.add(256);
			else
				msg.add(count % 257);
			
			SCServer.osc.send(msg, server.addr);
		}
				
		server.add_responder_b_setn(index, this, "getm_done");
	}
	
	public void getm_done(SCBuffer buffer, int frame, float [] values)
	{
		if (getm_remaining <= 0)
			return;

		for (int i = 0; i < values.length; i++)
		{
			getm_buffer[frame + i] = values[i];
		}
		
		if (--getm_remaining <= 0)
		{
			server.add_responder_b_setn(index, getm_target, getm_action);
			server.handle_b_setn(new Integer(index), new Integer(frame), new Integer(getm_count), getm_buffer);
		}
	}
	
	public void set(int frame, float value)
	{
		OscMessage msg = new OscMessage("/b_set");
		msg.add(index);
		msg.add(frame);
		msg.add(value);
		SCServer.osc.send(msg, server.addr);
	}
	
	public void set(int[] frames, float[] values)
	{
		OscMessage msg = new OscMessage("/b_set");
		
		msg.add(index);
		for (int i = 0; i < frames.length; i++)
		{
			msg.add(frames[i]);
			msg.add(values[i]);
		}
			
		SCServer.osc.send(msg, server.addr);
	}
	
	public void setn(int frame, int count, float[] values)
	{
		OscMessage msg = new OscMessage("/b_setn");
		msg.add(index);
		msg.add(frame);
		msg.add(count);
		for (int i = 0; i < values.length; i++)
			msg.add(values[i]);
		SCServer.osc.send(msg, server.addr);
	}
	
	public void fill(int frame, int count, float value)
	{
		OscMessage msg = new OscMessage("/b_fill");
		msg.add(index);
		msg.add(frame);
		msg.add(count);
		msg.add(value);
		SCServer.osc.send(msg, server.addr);		
	}

	public void zero()
	{
		OscMessage msg = new OscMessage("/b_zero");
		msg.add(index);
		SCServer.osc.send(msg, server.addr);		
	}
}

