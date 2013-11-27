package starling.display;

extern class Sprite extends DisplayObjectContainer {
	var clipRect : flash.geom.Rectangle;
	var isFlattened(default,never) : Bool;
	function new() : Void;
	function flatten() : Void;
	function getClipRect(p1 : DisplayObject, ?p2 : flash.geom.Rectangle) : flash.geom.Rectangle;
	function unflatten() : Void;
}
