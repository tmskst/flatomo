package starling.display;

extern class Quad extends DisplayObject {
	var color : UInt;
	var premultipliedAlpha(default,never) : Bool;
	var tinted(default,never) : Bool;
	function new(p1 : Float, p2 : Float, p3 : UInt = 0xFFFFFF, p4 : Bool = true) : Void;
	function copyVertexDataTo(p1 : starling.utils.VertexData, p2 : Int = 0) : Void;
	function copyVertexDataTransformedTo(p1 : starling.utils.VertexData, p2 : Int = 0, ?p3 : flash.geom.Matrix) : Void;
	function getVertexAlpha(p1 : Int) : Float;
	function getVertexColor(p1 : Int) : UInt;
	function setVertexAlpha(p1 : Int, p2 : Float) : Void;
	function setVertexColor(p1 : Int, p2 : UInt) : Void;
}
