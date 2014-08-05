package flatomo.display;

import flash.geom.Matrix;
import flatomo.Layout;

interface ILayoutAdjusted {
	/* Layout */
	private var transformationMatrix:Matrix;
	private var visible:Bool;
	
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
}
