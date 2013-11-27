package starling.utils;

extern class Color {
	function new() : Void;
	static var AQUA : UInt;
	static var BLACK : UInt;
	static var BLUE : UInt;
	static var FUCHSIA : UInt;
	static var GRAY : UInt;
	static var GREEN : UInt;
	static var LIME : UInt;
	static var MAROON : UInt;
	static var NAVY : UInt;
	static var OLIVE : UInt;
	static var PURPLE : UInt;
	static var RED : UInt;
	static var SILVER : UInt;
	static var TEAL : UInt;
	static var WHITE : UInt;
	static var YELLOW : UInt;
	static function argb(p1 : Int, p2 : Int, p3 : Int, p4 : Int) : UInt;
	static function getAlpha(p1 : UInt) : Int;
	static function getBlue(p1 : UInt) : Int;
	static function getGreen(p1 : UInt) : Int;
	static function getRed(p1 : UInt) : Int;
	static function rgb(p1 : Int, p2 : Int, p3 : Int) : UInt;
}
