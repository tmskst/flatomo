package starling.display;

extern class QuadBatch extends DisplayObject {
	var batchable : Bool;
	var capacity : Int;
	var numQuads(default,never) : Int;
	var premultipliedAlpha(default,never) : Bool;
	var smoothing(default,never) : String;
	var texture(default,never) : starling.textures.Texture;
	var tinted(default,never) : Bool;
	function new() : Void;
	function addImage(p1 : Image, p2 : Float = 1, ?p3 : flash.geom.Matrix, ?p4 : String) : Void;
	function addQuad(p1 : Quad, p2 : Float = 1, ?p3 : starling.textures.Texture, ?p4 : String, ?p5 : flash.geom.Matrix, ?p6 : String) : Void;
	function addQuadBatch(p1 : QuadBatch, p2 : Float = 1, ?p3 : flash.geom.Matrix, ?p4 : String) : Void;
	function clone() : QuadBatch;
	function getQuadAlpha(p1 : Int) : Float;
	function getQuadBounds(p1 : Int, ?p2 : flash.geom.Matrix, ?p3 : flash.geom.Rectangle) : flash.geom.Rectangle;
	function getQuadColor(p1 : Int) : UInt;
	function getVertexAlpha(p1 : Int, p2 : Int) : Float;
	function getVertexColor(p1 : Int, p2 : Int) : UInt;
	function isStateChange(p1 : Bool, p2 : Float, p3 : starling.textures.Texture, p4 : String, p5 : String, p6 : Int = 1) : Bool;
	function renderCustom(p1 : flash.geom.Matrix, p2 : Float = 1, ?p3 : String) : Void;
	function reset() : Void;
	function setQuadAlpha(p1 : Int, p2 : Float) : Void;
	function setQuadColor(p1 : Int, p2 : UInt) : Void;
	function setVertexAlpha(p1 : Int, p2 : Int, p3 : Float) : Void;
	function setVertexColor(p1 : Int, p2 : Int, p3 : UInt) : Void;
	function transformQuad(p1 : Int, p2 : flash.geom.Matrix) : Void;
	static var MAX_NUM_QUADS : Int;
	static function compile(p1 : DisplayObject, p2 : flash.Vector<QuadBatch>) : Void;
}
