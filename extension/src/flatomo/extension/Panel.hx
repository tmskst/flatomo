package flatomo.extention;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;

class Panel {
	public static function main() {
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.stage.align = StageAlign.TOP_LEFT;
	}
}
