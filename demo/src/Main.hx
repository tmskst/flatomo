package ;
import flash.xml.XML;
import flatomo.AssetFactory;
import flatomo.Flatomo;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
class Main extends Sprite {
	
	public function new() {
		super();
		
		var foobar = Flatomo.createTextureAtlas(new Config(), [TestMovie]);
		var af = AssetFactory.build(foobar);
		var tm = af.createInstance(TestMovie);
		untyped tm.advanceTime(1.0);
		addChild(tm);
		
	}
	
}
