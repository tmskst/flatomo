package starling.animation;

extern class DelayedCall extends starling.events.EventDispatcher implements IAnimatable {
	var currentTime(default,never) : Float;
	var isComplete(default,never) : Bool;
	var repeatCount : Int;
	var totalTime(default,never) : Float;
	function new(p1 : Dynamic, p2 : Float, ?p3 : Array<Dynamic>) : Void;
	function advanceTime(p1 : Float) : Void;
	function reset(p1 : flash.utils.Function, p2 : Float, ?p3 : Array<Dynamic>) : DelayedCall;
}
