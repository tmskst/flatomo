package starling.events;

extern class KeyboardEvent extends Event {
	var altKey(default,never) : Bool;
	var charCode(default,never) : UInt;
	var ctrlKey(default,never) : Bool;
	var keyCode(default,never) : UInt;
	var keyLocation(default,never) : UInt;
	var shiftKey(default,never) : Bool;
	function new(p1 : String, p2 : UInt = 0, p3 : UInt = 0, p4 : UInt = 0, p5 : Bool = false, p6 : Bool = false, p7 : Bool = false) : Void;
	function isDefaultPrevented() : Bool;
	function preventDefault() : Void;
	static var KEY_DOWN : String;
	static var KEY_UP : String;
}
