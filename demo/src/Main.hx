package ;
import flash.Lib;
import flatomo.Flatomo;
import starling.animation.IAnimatable;
import starling.animation.Juggler;
import starling.display.DisplayObject;
import starling.display.Sprite;

class Main extends Sprite {
	
	private var juggler:Juggler;
	
	public function new() {
		super();
		this.juggler = new Juggler();
		Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		
		Flatomo.start(new Config());
		var object:DisplayObject = cast(Flatomo.create(new TestMovie()), DisplayObject);
		juggler.add(cast(object, IAnimatable));
		this.addChild(object);
	}
	
	private function onEnterFrame(event:flash.events.Event):Void {
		juggler.advanceTime(1.0);
	}
	
}
