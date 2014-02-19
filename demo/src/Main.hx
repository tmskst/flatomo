package ;
import flatomo.Animation;
import flatomo.Container;
import flatomo.Flatomo;
import starling.display.DisplayObject;
import starling.display.Sprite;

class Main extends Sprite {
	
	public function new() {
		super();
		Flatomo.start(new Config());
		var object:DisplayObject = cast(Flatomo.create(new TestMovie()), DisplayObject);
		this.addChild(object);
	}
	
}
