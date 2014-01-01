package flatomo;
import flash.geom.Rectangle;
import flash.Vector;
import starling.display.MovieClip;
import starling.textures.Texture;

using flatomo.SectionTools;

class Animation extends MovieClip {
	
	public function new(textures:Vector<Texture>, sections:Array<Section>) {
		// Flatomo.juggler を使うのでFPSの指定はできない。
		super(textures, 1.00);
		this.codes = sections.toControlCodes();
	}
	
	private var codes:Map<Int, ControlCode>;
	
	public override function advanceTime(time:Float):Void {
		if (codes.exists(currentFrame)) {
			switch (codes.get(currentFrame)) {
				case ControlCode.Stop : 
					this.pause();
					return;
				case ControlCode.Goto(frame) :
					this.currentFrame = frame;
			}
		}
		super.advanceTime(time);
	}
	
}
