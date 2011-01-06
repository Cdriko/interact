package jp.nyatla.nyar4psg;

import javax.media.opengl.GL;

import jp.nyatla.nyartoolkit.core.squaredetect.NyARSquare;
import jp.nyatla.nyartoolkit.core.transmat.NyARTransMatResult;
import jp.nyatla.nyartoolkit.core.types.NyARDoublePoint2d;
import jp.nyatla.nyartoolkit.core.types.NyARDoublePoint3d;
import processing.core.PApplet;
import processing.core.PMatrix3D;
import processing.core.PVector;
import processing.opengl.PGraphicsOpenGL;

/**
 * 
 * Companion class to NyARMultiBoard that simplifies multiple marker tracking using
 * NyARToolkit for processing.  See the NyARMultiBoard documentation for more details.
 * 
 * @author Charl P. Botha http://cpbotha.net/
 *
 */
public class NyARMultiBoardMarker {
	/**
	 * The angle value in radian unit of "x,y,z" .
	 */
	public PVector angle;
	/**
	 * The translation value in radian unit of "x,y,z".
	 */
	public PVector trans;
	/**
	 * The position of 4 corner of marker.
	 */
	public int[][] pos2d;
	/**
	 * The transform matrix of detected marker.
	 */
	public double[] transmat;
	
	/**
	 * Was this marker detected during the previous round?
	 */
	public boolean detected = false;
	
	/**
	 * The confidence value of detected marker.
	 */
	public double confidence=0.0;
	
	/**
	 * It is a number in which it continuously lost the marker.
	 * This value range is "0&lt;n&lt;lostDelay"
	 */
	public int lostCount = 0;
	
	
	/**
	 * Store instance of the board that holds us.
	 */
	protected NyARMultiBoard _board;
	
	public NyARMultiBoardMarker(NyARMultiBoard board)
	{
		this._board = board;
	
		this.angle=new PVector();
		this.trans=new PVector();
		this.pos2d=new int[4][2];
		this.transmat=new double[16];
	}
		
	/**
	 * This function sets corresponding transform matrix to the surface of the marker to OpenGL.
	 * The coordinate system of processing moves to the surface of the marker when this function is executed.
	 * Must return the coordinate system by using endTransform function at the end.
	 * @param i_pgl
	 * Specify PGraphicsOpenGL instance.
	 * Set cast "g" member of processing graphics object.
	 */
	public void beginTransform(PGraphicsOpenGL i_pgl)
	{
		PApplet pa = this._board.get_papplet();
		if(this._gl!=null){
			pa.die("The function beginTransform is already called.", null);			
		}
		this._pgl=i_pgl;
		this._gl=this._pgl.beginGL();

		
		this._gl=i_pgl.gl;
		this._gl.glMatrixMode(GL.GL_PROJECTION);
		pa.pushMatrix();
		pa.resetMatrix();
		//PGraphicsOpenGLのupdateProjectionのモノマネをします。
		this._gl.glLoadMatrixd(this._board.projection,0);
		this._old_matrix=this._pgl.projection;
		this._pgl.projection=this._board.get_ps_projection();


		this._gl.glMatrixMode(GL.GL_MODELVIEW);
		pa.pushMatrix();
		pa.resetMatrix();
		this._gl.glLoadMatrixd(this.transmat,0);
				
		pa.pushMatrix();
		return;	
	}
	/**
	 * This function recover coordinate system that was changed by beginTransform function.
	 */
	public void endTransform()
	{
		PApplet pa = this._board.get_papplet();
		if(this._gl==null){
			pa.die("The function beginTransform is never called.", null);			
		}
		this._pgl.projection=this._old_matrix;
		pa.popMatrix();
		pa.popMatrix();
		this._gl.glMatrixMode(GL.GL_PROJECTION);
		pa.popMatrix();
		this._gl.glMatrixMode(GL.GL_MODELVIEW);
		if(this._pgl!=null){
			this._pgl.endGL();
		}
		this._gl=null;
		this._pgl=null;
		return;
	}	
	protected void updateTransmat(NyARSquare i_square,NyARTransMatResult i_src)
	{
		NyARPsgBaseClass.matResult2GLArray(i_src,this.transmat);
		//angle
		i_src.getZXYAngle(this._tmp_d3p);
		
		this.angle.x=(float)this._tmp_d3p.x;
		this.angle.y=(float)this._tmp_d3p.y;
		this.angle.z=(float)this._tmp_d3p.z;
		//trans
		this.trans.x=(float)i_src.m03;
		this.trans.y=(float)i_src.m13;
		this.trans.z=(float)i_src.m23;

		//pos反映
		final NyARDoublePoint2d[] pts=i_square.sqvertex;
		for(int i=0;i<4;i++){
			this.pos2d[i][0]=(int)pts[i].x;
			this.pos2d[i][1]=(int)pts[i].y;
		}		
		
		return;	
	}
	/********
	 * 	protected/private
	 *******/
	private final NyARDoublePoint3d _tmp_d3p=new NyARDoublePoint3d();
	
	
	//キャッシュたち
	private GL _gl=null;
	private PGraphicsOpenGL _pgl=null;	
	private PMatrix3D _old_matrix;
	

}
