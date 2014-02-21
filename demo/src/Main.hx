package ;
import flash.events.Event;
import flash.Lib;
import flatomo.Flatomo;
import starling.animation.Juggler;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.utils.AssetManager;

class Main extends Sprite {
	
	private var juggler:Juggler;
	
	public function new() {
		super();
		this.juggler = new Juggler();
		
		var flatomo:Flatomo = new Flatomo(new Config());
		var asset = new AssetManager();
		asset.addTextureAtlas("dummy", flatomo.create([TestMovie]));
		for (i in 0...10) {
			var m = new MovieClip(asset.getTextures("F:TestMovie"));
			m.x = Std.random(400);
			m.y = Std.random(600);
			addChild(m);
			juggler.add(m);
		}
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event):Void {
		juggler.advanceTime(1/30);
	}
	
}
