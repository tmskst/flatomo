package starling.events;

extern class TouchMarker extends starling.display.Sprite {
	var mockX(default,never) : Float;
	var mockY(default,never) : Float;
	var realX(default,never) : Float;
	var realY(default,never) : Float;
	function new() : Void;
	function moveCenter(p1 : Float, p2 : Float) : Void;
	function moveMarker(p1 : Float, p2 : Float, p3 : Bool = false) : Void;
}
