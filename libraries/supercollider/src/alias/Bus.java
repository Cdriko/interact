package supercollider;

public class Bus extends SCBus
{ 
	public Bus() { super(); }
	public Bus(int channels) { super(channels); }
	public Bus(String type, int channels) { super(type, channels); }
	public Bus (String type, SCServer server, int channels) { super(type, server, channels); }
}
