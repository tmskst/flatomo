package ;
import flatomo.Flatomo;
import flatomo.FlatomoAssetManager;
import starling.display.Sprite;

using flatomo.FlatomoAssetManager;

class Main extends Sprite {
	
	public function new() {
		super();
		
		var foobar1 = Flatomo.createTextureAtlas(new foobar.Foobar(), [foobar.TestMovie]);
		var manager1 = foobar1.build();
		var object1 = manager1.createInstance(foobar.TestMovie);
		untyped object1.advanceTime(1.0);
		addChild(object1);
		
		var foobar2 = Flatomo.createTextureAtlas(new hoge.Hoge(), [hoge.TestMovie]);
		var manager2 = foobar2.build();
		var object2 = manager2.createInstance(hoge.TestMovie);
		object2.x = 100;
		untyped object2.advanceTime(1.0);
		addChild(object2);
	}
	
}
