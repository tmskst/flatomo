package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import starling.display.Image;
import starling.textures.Texture;

class FlatomoImage extends Image implements ILayoutAdjusted {

	@:allow(flatomo.GpuOperator)
	private function new(layouts:Array<Layout>, texture:Texture) {
		super(texture);
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
	}
	
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
}
