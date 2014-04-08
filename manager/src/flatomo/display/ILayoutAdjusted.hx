package flatomo.display;

import haxe.ds.Vector;
import flatomo.Layout;

@:allow(flatomo.display.LayoutAdjustedTools)
interface ILayoutAdjusted {
	private var locked:Bool;
	private var layouts:Vector<Layout>;
}
