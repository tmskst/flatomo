package flatomo.display;

import flash.geom.Matrix;
import flatomo.Layout;
import haxe.ds.Vector;

interface ILayoutAdjusted {
	/* Layout */
	private var transformationMatrix:Matrix;
	private var visible:Bool;
	
	private var layouts:Vector<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
}
