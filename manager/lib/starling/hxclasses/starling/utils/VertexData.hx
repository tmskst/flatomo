package starling.utils;

extern class VertexData {
	var numVertices : Int;
	var premultipliedAlpha : Bool;
	var rawData(default,never) : flash.Vector<Float>;
	var tinted(default,never) : Bool;
	function new(p1 : Int, p2 : Bool = false) : Void;
	function append(p1 : VertexData) : Void;
	function clone(p1 : Int = 0, p2 : Int = -1) : VertexData;
	function copyTo(p1 : VertexData, p2 : Int = 0, p3 : Int = 0, p4 : Int = -1) : Void;
	function copyTransformedTo(p1 : VertexData, p2 : Int = 0, ?p3 : flash.geom.Matrix, p4 : Int = 0, p5 : Int = -1) : Void;
	function getAlpha(p1 : Int) : Float;
	function getBounds(?p1 : flash.geom.Matrix, p2 : Int = 0, p3 : Int = -1, ?p4 : flash.geom.Rectangle) : flash.geom.Rectangle;
	function getColor(p1 : Int) : UInt;
	function getPosition(p1 : Int, p2 : flash.geom.Point) : Void;
	function getTexCoords(p1 : Int, p2 : flash.geom.Point) : Void;
	function scaleAlpha(p1 : Int, p2 : Float, p3 : Int = 1) : Void;
	function setAlpha(p1 : Int, p2 : Float) : Void;
	function setColor(p1 : Int, p2 : UInt) : Void;
	function setColorAndAlpha(p1 : Int, p2 : UInt, p3 : Float) : Void;
	function setPosition(p1 : Int, p2 : Float, p3 : Float) : Void;
	function setPremultipliedAlpha(p1 : Bool, p2 : Bool = true) : Void;
	function setTexCoords(p1 : Int, p2 : Float, p3 : Float) : Void;
	function setUniformAlpha(p1 : Float) : Void;
	function setUniformColor(p1 : UInt) : Void;
	function toString() : String;
	function transformVertex(p1 : Int, p2 : flash.geom.Matrix, p3 : Int = 1) : Void;
	function translateVertex(p1 : Int, p2 : Float, p3 : Float) : Void;
	static var COLOR_OFFSET : Int;
	static var ELEMENTS_PER_VERTEX : Int;
	static var POSITION_OFFSET : Int;
	static var TEXCOORD_OFFSET : Int;
}
