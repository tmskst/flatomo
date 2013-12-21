package starling.events;

extern class ResizeEvent extends Event {
	var height(default,never) : Int;
	var width(default,never) : Int;
	function new(p1 : String, p2 : Int, p3 : Int, p4 : Bool = false) : Void;
	static var RESIZE : String;
}
