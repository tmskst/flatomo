package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import haxe.ds.Vector.Vector;
import starling.display.Image;
import starling.textures.Texture;

class FlatomoImage extends Image implements ILayoutAdjusted {

	public function new(layouts:Vector<Layout>, p1:Texture) {
		super(p1);
		this.locked = false;
		this.layouts = layouts;
	}
	
	private var locked:Bool;
	private var layouts:Vector<Layout>;
	
}
