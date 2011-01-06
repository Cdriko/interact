/*
 * NyARMultiBoard.java
 * 
 * Coded by Charl P. Botha http://cpbotha.net/ for simplifying multiple marker tracking
 * using NyARToolkit from processing.
 * 
 * Very important:
 * This has been tested with processing 1.1 and NyARToolkit 2.5.2.
 * You either HAVE to add the following method to NyARDetectMarker in NyARToolkit:
 * public NyARSquare refSquare(int i_index)
   {
            return this._detect_cb.result_stack.getItem(i_index).square;
   }
 * and rebuild it, or just download my patched NyARToolkit jar file.
 * 
 * All of the modifications to NyARToolkit for Processing are of course also under the same license.
 * 
 */

package jp.nyatla.nyar4psg;
import jp.nyatla.nyartoolkit.NyARException;
import jp.nyatla.nyartoolkit.core.NyARCode;
import jp.nyatla.nyartoolkit.core.transmat.NyARTransMatResult;
import jp.nyatla.nyartoolkit.detector.NyARDetectMarker;
import processing.core.*;

/**
 * NyARToolkit for processing class for tracking multiple markers.
 *
 * Acts as the main interface class between processing and NyARToolkit.  Pass it an array
 * of pattern files as well as an array of pattern file widths, then use as per other examples.
 * 
 * In your draw() method, call detect() in this instance.  Public markers list contains
 * NyARMultiBoardMarker instances, each of which, if its detected ivar is true, gives
 * information about the marker detection.
 * 
 * See NyARMultiTest sketchbook for an example of its use.
 * 
 * History:
 * 20100605 Finally added method to NyARDetectMarker class in NyARToolkit that exposes 
 * _detect_cb.result_stack.getItem(i_index).square, so that we can now use NyARDetectMarker
 * to detect bunches of markers in one go. Should be more efficient.
 * 20100604 First working attempt used a list of NyARSingleDetectMarkers, but this probably has
 * unnecessary overhead.  
 * 
 * @author Charl P. Botha http://cpbotha.net/
 */
public class NyARMultiBoard extends NyARPsgBaseClass {
	/**
	 * NyARBoard ignores that it lost the marker while under specified number.
	 * Must be "n&gt;=0".
	 */
	public int lostDelay =10;

	/**
	 * The threshold value of marker pattern confidence, between 0.0 and 1.0.
	 * When marker confidence is larger than this value, NyARBoard detects the marker.
	 */
	public double cfThreshold=0.4;

	/**
	 * The threshold value of labeling process from gray scale image.
	 * This value range is 0 to 255.
	 */
	public int gsThreshold=110;
	

	private PImageRaster _raster;
	
	public NyARMultiBoardMarker[] markers;
	
	public NyARDetectMarker _nyardm;
	
	/**
	 * This function is constructor.
	 * @param parent
	 * Specify processing instance.
	 * @param i_width
	 * Width of source image size for "detect()".
	 * @param i_htight
	 * Height of source image size for "detect()".
	 * @param i_cparam
	 * The file name of the camera parameter of ARToolKit format.
	 * Place the file to "data" directory at sketch.
	 * @param i_patts
	 * List containing filenames of ARToolkit marker patterns.
	 * The files have to be in the data subdirectory of the sketch.
	 * The marker resolution must be 16x16.
	 * @param i_patt_widths
	 * List of lengths in mm corresponding to the pattern files specified above.
	 * @param i_projection_coord_system
	 * Coordinate system flag of projection Matrix. Should be NyARBoard.CS_RIGHT or NyARBoard.Left(default)
	 */
	public NyARMultiBoard(PApplet parent, int i_width,int i_height,String i_cparam,String[] i_patts,double[] i_patt_widths,int i_projection_coord_system)
	{
		super(parent,i_cparam,i_width,i_height,i_projection_coord_system);
		initInstance(i_width,i_height,i_patts,i_patt_widths);
		return;
	}
	/**
	 * This function is constructor same as i_projection_coord_system=CS_LEFT.
	 * @param parent
	 * Specify processing instance.
	 * @param i_width
	 * Width of source image size for "detect()".
	 * @param i_htight
	 * Height of source image size for "detect()".
	 * @param i_cparam
	 * The file name of the camera parameter of ARToolKit format.
	 * Place the file to "data" directory at sketch.
	 * @param i_patt
	 * The file name of the marker pattern file of ARToolkit.
	 * Place the file to "data" directory at sketch.
	 * The marker resolution must be 16x16.
	 * @param i_patt_width
	 * The length of one side of a square marker in millimeter unit.
	 */	
	public NyARMultiBoard(PApplet parent, int i_width,int i_height,String i_cparam,String[] i_patts,double[] i_patt_widths)
	{
		// call into NyARPsgBaseClass
		super(parent,i_cparam,i_width,i_height,CS_LEFT);
		initInstance(i_width,i_height,i_patts,i_patt_widths);
		return;
	}
	
	private void initInstance(int i_width,int i_height,String[] i_patts,double[] i_patt_widths)
	{
		try{
			this._raster=new PImageRaster(i_width, i_height);
			this.markers = new NyARMultiBoardMarker[i_patts.length];
			NyARCode[] codes = new NyARCode[i_patts.length];
			
			for (int i = 0; i < i_patts.length; i++)
			{
				codes[i]=new NyARCode(16,16);
				codes[i].loadARPatt(this._pa.createInput(i_patts[i]));
				this.markers[i] = new NyARMultiBoardMarker(this);
				this.markers[i].lostCount = this.lostDelay;
			}
			// this will do all the hard work of detecting all markers
			this._nyardm = new NyARDetectMarker(this._ar_param, codes, i_patt_widths, i_patts.length, this._raster.getBufferType());
		}catch(NyARException e){
			this._pa.die("Error while setting up NyARToolkit for java", e);
		}
		return;
	}
	
	/**
	 * This function detect a marker which is must higher confidence in i_image.
	 * When function detects marker, properties (pos2d,angle,trans,confidence,transmat) are updated.
	 * @param i_image
	 * Specify source image.
	 * @return
	 * TRUE if marker found;otherwise FALSE.
	 */
	public boolean detect(PImage i_image)
	{
		int num_detected;
		int markers_found = 0;
		NyARTransMatResult result=new NyARTransMatResult();		
		try{
			this._raster.wrapBuffer(i_image);
			num_detected = this._nyardm.detectMarkerLite(this._raster, this.gsThreshold);
			// default situation: no markers detected.
			for (int i = 0; i < this.markers.length; i++)
			{
				this.markers[i].detected = false;
			}
			// then go through the detected ones, copying info where detection confidence is high enough
			for (int det_i = 0; det_i < num_detected; det_i++)
			{
				double conf = this._nyardm.getConfidence(det_i);
				if (conf >= this.cfThreshold)
				{
					int marker_i = this._nyardm.getARCodeIndex(det_i);
					this.markers[marker_i].confidence = conf;
					this.markers[marker_i].detected = true;
					this.markers[marker_i].lostCount = 0;
					this._nyardm.getTransmationMatrix(det_i, result);
					this.markers[marker_i].updateTransmat(this._nyardm.refSquare(det_i), result);
					markers_found++;
				}
				
			}
			// go through the markers again: those that were recently detected remain
			// detected.
			for (int i = 0; i < this.markers.length; i++)
			{
				if (!this.markers[i].detected && this.markers[i].lostCount < this.lostDelay)
				{
					this.markers[i].detected = true;
					this.markers[i].lostCount++;
					markers_found++;
				}
				
			}
			
		}catch(NyARException e){
			this._pa.die("Error while marker detecting up NyARToolkit for java", e);
		}
		
		return (markers_found >0);
	}
	
	public PApplet get_papplet()
	{
		return this._pa;
	}
	
	public PMatrix3D get_ps_projection()
	{
		return this._ps_projection;
	}


}
