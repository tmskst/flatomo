package starling.utils;

extern class SystemUtil {
	function new() : Void;
	static var isAIR(default,never) : Bool;
	static var isApplicationActive(default,never) : Bool;
	static var isDesktop(default,never) : Bool;
	static var platform(default,never) : String;
	static function executeWhenApplicationIsActive(p1 : Dynamic, ?p2 : Dynamic, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic, ?p6 : Dynamic) : Void;
	static function initialize() : Void;
}
