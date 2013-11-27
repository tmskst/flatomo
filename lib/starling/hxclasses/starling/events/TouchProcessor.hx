package starling.events;

extern class TouchProcessor {
	var multitapDistance : Float;
	var multitapTime : Float;
	var root : starling.display.DisplayObject;
	var simulateMultitouch : Bool;
	var stage(default,never) : starling.display.Stage;
	function new(p1 : starling.display.Stage) : Void;
	function advanceTime(p1 : Float) : Void;
	function dispose() : Void;
	function enqueue(p1 : Int, p2 : String, p3 : Float, p4 : Float, p5 : Float = 1, p6 : Float = 1, p7 : Float = 1) : Void;
	function enqueueMouseLeftStage() : Void;
}
