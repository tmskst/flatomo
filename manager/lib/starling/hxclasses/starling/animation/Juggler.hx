package starling.animation;

extern class Juggler implements IAnimatable {
	var elapsedTime(default,never) : Float;
	var objects(default,never) : flash.Vector<IAnimatable>;
	function new() : Void;
	function add(p1 : IAnimatable) : Void;
	function advanceTime(p1 : Float) : Void;
	function contains(p1 : IAnimatable) : Bool;
	function containsTweens(p1 : flash.utils.Object) : Bool;
	function delayCall(p1 : flash.utils.Function, p2 : Float, ?p3 : Dynamic, ?p4 : Dynamic, ?p5 : Dynamic, ?p6 : Dynamic, ?p7 : Dynamic) : IAnimatable;
	function purge() : Void;
	function remove(p1 : IAnimatable) : Void;
	function removeTweens(p1 : flash.utils.Object) : Void;
	function repeatCall(p1 : flash.utils.Function, p2 : Float, p3 : Int = 0, ?p4 : Dynamic, ?p5 : Dynamic, ?p6 : Dynamic, ?p7 : Dynamic, ?p8 : Dynamic) : IAnimatable;
	function tween(p1 : flash.utils.Object, p2 : Float, p3 : flash.utils.Object) : IAnimatable;
}
