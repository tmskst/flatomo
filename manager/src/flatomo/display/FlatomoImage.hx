package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import haxe.ds.Vector.Vector;
import starling.display.Image;
import starling.textures.Texture;

class FlatomoImage extends Image implements ILayoutAdjusted {

	public function new(layouts:Vector<Layout>, p1:Texture) {
		super(p1);
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
		this.layouts = layouts;
	}
	
	public var layoutPropertiesOverwrited:Bool;
	public var visiblePropertyOverwrited:Bool;
	public var layouts:Vector<Layout>;
	
}
