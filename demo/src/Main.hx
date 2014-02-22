package ;
import flatomo.Creator;
import flatomo.Flatomo;
import flatomo.FlatomoTools;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.utils.AssetManager;

class Main extends Sprite {
	
	public function new() {
		super();
		
		var foobar = Flatomo.createTextureAtlas(new Config(), [TestMovie]);
		var asset = new AssetManager();
		asset.addTextureAtlas("foobar", foobar);
	}
	
}
