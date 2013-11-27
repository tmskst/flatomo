package starling.events;

extern class Touch {
	var bubbleChain(default,never) : flash.Vector<EventDispatcher>;
	var globalX : Float;
	var globalY : Float;
	var height : Float;
	var id(default,never) : Int;
	var phase : String;
	var pressure : Float;
	var previousGlobalX(default,never) : Float;
	var previousGlobalY(default,never) : Float;
	var tapCount : Int;
	var target : starling.display.DisplayObject;
	var timestamp : Float;
	var width : Float;
	function new(p1 : Int) : Void;
	function clone() : Touch;
	function dispatchEvent(p1 : TouchEvent) : Void;
	function getLocation(p1 : starling.display.DisplayObject, ?p2 : flash.geom.Point) : flash.geom.Point;
	function getMovement(p1 : starling.display.DisplayObject, ?p2 : flash.geom.Point) : flash.geom.Point;
	function getPreviousLocation(p1 : starling.display.DisplayObject, ?p2 : flash.geom.Point) : flash.geom.Point;
	function isTouching(p1 : starling.display.DisplayObject) : Bool;
	function toString() : String;
}
