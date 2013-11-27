package starling.display;

extern class BlendMode {
	function new() : Void;
	static var ADD : String;
	static var AUTO : String;
	static var ERASE : String;
	static var MULTIPLY : String;
	static var NONE : String;
	static var NORMAL : String;
	static var SCREEN : String;
	static function getBlendFactors(p1 : String, p2 : Bool = true) : Array<Dynamic>;
	static function register(p1 : String, p2 : String, p3 : String, p4 : Bool = true) : Void;
}
