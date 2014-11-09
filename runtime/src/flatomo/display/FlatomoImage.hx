package flatomo.display;

import flash.geom.Matrix;
import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import starling.display.Image;
import starling.textures.Texture;

class FlatomoImage extends Image implements ILayoutAdjusted {

	@:allow(flatomo.GpuOperator)
	private function new(layouts:Array<Layout>, texture:Texture, matrix:Matrix) {
		super(texture);
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
		this.matrix = matrix;
	}
	
	private var matrix:Matrix;
	
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
	public override function dispose():Void {
		this.matrix = null;
		this.layouts = null;
		super.dispose();
	}
	
}
