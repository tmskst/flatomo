package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import haxe.ds.Vector.Vector;
import starling.display.Image;
import starling.textures.Texture;

class FlatomoImage extends Image implements ILayoutAdjusted {

	public function new(layouts:Vector<Layout>, texture:Texture) {
		super(texture);
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
	}
	
	private var layouts:Vector<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
}
