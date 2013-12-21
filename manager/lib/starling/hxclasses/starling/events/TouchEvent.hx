package starling.events;

extern class TouchEvent extends Event {
	var ctrlKey(default,never) : Bool;
	var shiftKey(default,never) : Bool;
	var timestamp(default,never) : Float;
	var touches(default,never) : flash.Vector<Touch>;
	function new(p1 : String, p2 : flash.Vector<Touch>, p3 : Bool = false, p4 : Bool = false, p5 : Bool = true) : Void;
	function dispatch(p1 : flash.Vector<EventDispatcher>) : Void;
	function getTouch(p1 : starling.display.DisplayObject, ?p2 : String, p3 : Int = -1) : Touch;
	function getTouches(p1 : starling.display.DisplayObject, ?p2 : String, ?p3 : flash.Vector<Touch>) : flash.Vector<Touch>;
	function interactsWith(p1 : starling.display.DisplayObject) : Bool;
	static var TOUCH : String;
}
