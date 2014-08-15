package starling.animation;

extern class Transitions {
	function new() : Void;
	static var EASE_IN : String;
	static var EASE_IN_BACK : String;
	static var EASE_IN_BOUNCE : String;
	static var EASE_IN_ELASTIC : String;
	static var EASE_IN_OUT : String;
	static var EASE_IN_OUT_BACK : String;
	static var EASE_IN_OUT_BOUNCE : String;
	static var EASE_IN_OUT_ELASTIC : String;
	static var EASE_OUT : String;
	static var EASE_OUT_BACK : String;
	static var EASE_OUT_BOUNCE : String;
	static var EASE_OUT_ELASTIC : String;
	static var EASE_OUT_IN : String;
	static var EASE_OUT_IN_BACK : String;
	static var EASE_OUT_IN_BOUNCE : String;
	static var EASE_OUT_IN_ELASTIC : String;
	static var LINEAR : String;
	static function getTransition(p1 : String) : Dynamic;
	static function register(p1 : String, p2 : Dynamic) : Void;
}
