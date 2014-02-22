package ;
import flatomo.Creator;
import starling.display.Sprite;

class Main extends Sprite {
	
	@:access(flatomo.Creator)
	public function new() {
		super();
		var foobar:Creator = new Creator(new Config());
		foobar.create([TestMovie]);
		trace(foobar.images);
		trace(foobar.meta);
	}
	
}
