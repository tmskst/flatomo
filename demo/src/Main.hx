package ;
import flatomo.Flatomo;
import flatomo.FlatomoAssetManager;
import starling.display.Sprite;

using flatomo.FlatomoAssetManager;

class Main extends Sprite {
	
	public function new() {
		super();
		
		var foobar = Flatomo.createTextureAtlas(new Config(), [TestMovie]);
		var manager = foobar.build();
		var object = manager.createInstance(TestMovie);
		untyped object.advanceTime(1.0);
		addChild(object);
	}
	
}
