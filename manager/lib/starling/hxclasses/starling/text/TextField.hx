package starling.text;

extern class TextField extends starling.display.DisplayObjectContainer {
	var autoScale : Bool;
	var autoSize : String;
	var batchable : Bool;
	var bold : Bool;
	var border : Bool;
	var color : UInt;
	var fontName : String;
	var fontSize : Float;
	var hAlign : String;
	var italic : Bool;
	var kerning : Bool;
	var nativeFilters : Array<Dynamic>;
	var text : String;
	var textBounds(default,never) : flash.geom.Rectangle;
	var underline : Bool;
	var vAlign : String;
	function new(p1 : Int, p2 : Int, p3 : String, ?p4 : String, p5 : Float = 12, p6 : UInt = 0, p7 : Bool = false) : Void;
	function redraw() : Void;
	static function getBitmapFont(p1 : String) : BitmapFont;
	static function registerBitmapFont(p1 : BitmapFont, ?p2 : String) : String;
	static function unregisterBitmapFont(p1 : String, p2 : Bool = true) : Void;
}
