package flatomo.display;

import haxe.ds.Vector;
import flatomo.Layout;

interface ILayoutAdjusted {
	/* Layout */
	private var x:Float;
	private var y:Float;
	private var rotation:Float;
	private var scaleX:Float;
	private var scaleY:Float;
	private var visible:Bool;
	
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	private var layouts:Vector<Layout>;
}
