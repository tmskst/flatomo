package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import haxe.ds.Vector;
import starling.text.TextField;

class FlatomoTextField extends TextField implements ILayoutAdjusted {
	
	public function new(layouts:Vector<Layout>, p1:Int, p2:Int, p3:String, ?p4:String, ?p5:Float = 12, ?p6:UInt = 0, ?p7:Bool = false) {
		super(p1, p2, p3, p4, p5, p6, p7);
		this.locked = false;
		this.layouts = layouts;
	}
	
	private var locked:Bool;
	private var layouts:Vector<Layout>;
	
}
