package ;
import flash.Lib;
import flatomo.Animation;
import flatomo.Flatomo;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;

using flatomo.FlatomoAssetManager;

class Main {
	
	public static function main() {
		new Main();
	}
	
	public function new() {
		var myStarling = new Starling(Sprite, Lib.current.stage);
		myStarling.addEventListener(Event.ROOT_CREATED, starlingInitialized);
		myStarling.start();
	}
	
	private function starlingInitialized(event:Event):Void {
		var stage = Starling.current.stage;
		var fam = Flatomo.createTextureAtlas(new foobar.Foobar(), [foobar.TestMovie]).build();
		var object = cast(fam.createInstance(foobar.TestMovie), Animation);
		stage.addChild(object);
	}
	
}
