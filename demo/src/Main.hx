package ;
import flatomo.Creator;
import flatomo.FlatomoTools;
import starling.display.Sprite;

class Main extends Sprite {
	
	@:access(flatomo.FlatomoTools)
	public function new() {
		super();
		
		var library = FlatomoTools.fetchLibrary(new Config());
		var foobar = Creator.create(library, [TestMovie]);
		trace(foobar.images);
		trace(foobar.meta);
	}
	
}
