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
		// TODO: ライブラリ項目が持つ制御コードだから、本来マップは1つで十分。仮実装。
		this.codes = sections.toCodes();
	}
	
	private var codes:Map<Int, ControlCode>;
	
	public override function advanceTime(time:Float):Void {
		var nextFrame:Int = this.currentFrame + 1;
		if (codes.exists(nextFrame)) {
			var code:ControlCode = codes.get(nextFrame);
			switch (code) {
				case ControlCode.Stop : 
					this.pause();
				case ControlCode.Goto(frame) :
					this.currentFrame = frame - 1;
			}
		}
		super.advanceTime(time);
	}
	
}