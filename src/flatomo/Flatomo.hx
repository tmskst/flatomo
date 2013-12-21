package flatomo;
import flash.events.Event;
import flash.Lib;
import starling.animation.Juggler;
import starling.display.DisplayObject;

class Flatomo {
	
	public static function start():Void {
		if (isStarted) {
			return;
		}
		flatomo = new Flatomo();
	}
	
	public static function create(source:flash.display.DisplayObject):DisplayObject {
		return Creator.translate(source);
	}
	
	private function new() {
		Flatomo.isStarted = true;
		Flatomo.juggler = new Juggler();
		Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:flash.events.Event):Void {
		juggler.advanceTime(1.00);
	}
	
	private static var flatomo:Flatomo = null;
	private static var isStarted:Bool = false;
	
	public static var juggler(default, null):Juggler = null;
	
	
}