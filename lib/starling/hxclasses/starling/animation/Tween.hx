package starling.animation;

extern class Tween extends starling.events.EventDispatcher implements IAnimatable {
	var currentTime(default,never) : Float;
	var delay : Float;
	var isComplete(default,never) : Bool;
	var nextTween : Tween;
	var onComplete : Dynamic;
	var onCompleteArgs : Array<Dynamic>;
	var onRepeat : Dynamic;
	var onRepeatArgs : Array<Dynamic>;
	var onStart : Dynamic;
	var onStartArgs : Array<Dynamic>;
	var onUpdate : Dynamic;
	var onUpdateArgs : Array<Dynamic>;
	var progress(default,never) : Float;
	var repeatCount : Int;
	var repeatDelay : Float;
	var reverse : Bool;
	var roundToInt : Bool;
	var target(default,never) : Dynamic;
	var totalTime(default,never) : Float;
	var transition : String;
	var transitionFunc : Dynamic;
	function new(p1 : Dynamic, p2 : Float, ?p3 : Dynamic) : Void;
	function advanceTime(p1 : Float) : Void;
	function animate(p1 : String, p2 : Float) : Void;
	function fadeTo(p1 : Float) : Void;
	function getEndValue(p1 : String) : Float;
	function moveTo(p1 : Float, p2 : Float) : Void;
	function reset(p1 : flash.utils.Object, p2 : Float, ?p3 : flash.utils.Object) : Tween;
	function scaleTo(p1 : Float) : Void;
	static function fromPool(p1 : Dynamic, p2 : Float, ?p3 : Dynamic) : Tween;
	static function toPool(p1 : Tween) : Void;
}
