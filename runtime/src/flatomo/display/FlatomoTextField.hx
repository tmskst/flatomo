package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import starling.text.TextField;

class FlatomoTextField extends TextField implements ILayoutAdjusted {
	
	@:allow(flatomo.GpuOperator)
	private function new(layouts:Array<Layout>, width:Int, height:Int, text:String, fontName:String, ?fontSize:Float = 12, ?color:UInt = 0x0, ?bold:Bool = false) {
		super(width, height, text, fontName, fontSize, color, bold);
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
	}
	
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
}