package starling.events;

extern class EnterFrameEvent extends Event {
	var passedTime(default,never) : Float;
	function new(p1 : String, p2 : Float, p3 : Bool = false) : Void;
	static var ENTER_FRAME : String;
}
