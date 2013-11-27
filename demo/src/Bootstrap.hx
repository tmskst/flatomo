package ;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.geom.Rectangle;
import flash.Lib;
import starling.core.Starling;
import starling.utils.HAlign;
import starling.utils.VAlign;

class Bootstrap {
	public static function main() {
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		var s = new Starling(Main, Lib.current.stage, new Rectangle(0, 0, 480, 720));
		s.showStats = true;
		s.showStatsAt(HAlign.LEFT, VAlign.BOTTOM);
		s.start();
	}
}