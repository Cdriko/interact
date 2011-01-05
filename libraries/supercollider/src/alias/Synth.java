package supercollider;

public class Synth extends SCSynth
{
	public Synth() { super(); }
	public Synth(String synthname) { super(synthname); }
	public Synth(String synthname, SCServer server) { super(synthname, server); }
	public Synth(String synthname, SCGroup group) { super(synthname, group); }

}
