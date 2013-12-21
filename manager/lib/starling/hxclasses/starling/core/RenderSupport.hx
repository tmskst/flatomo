package starling.core;

extern class RenderSupport {
	var blendMode : String;
	var drawCount(default,never) : Int;
	var modelViewMatrix(default,never) : flash.geom.Matrix;
	var mvpMatrix(default,never) : flash.geom.Matrix;
	var mvpMatrix3D(default,never) : flash.geom.Matrix3D;
	var projectionMatrix : flash.geom.Matrix;
	var renderTarget : starling.textures.Texture;
	function new() : Void;
	function applyBlendMode(p1 : Bool) : Void;
	function applyClipRect() : Void;
	function batchQuad(p1 : starling.display.Quad, p2 : Float, ?p3 : starling.textures.Texture, ?p4 : String) : Void;
	function batchQuadBatch(p1 : starling.display.QuadBatch, p2 : Float) : Void;
	function clear__(p1 : UInt = 0, p2 : Float = 0) : Void;
	function dispose() : Void;
	function finishQuadBatch() : Void;
	function loadIdentity() : Void;
	function nextFrame() : Void;
	function popClipRect() : Void;
	function popMatrix() : Void;
	function prependMatrix(p1 : flash.geom.Matrix) : Void;
	function pushClipRect(p1 : flash.geom.Rectangle) : flash.geom.Rectangle;
	function pushMatrix() : Void;
	function raiseDrawCount(p1 : UInt = 1) : Void;
	function resetMatrix() : Void;
	function rotateMatrix(p1 : Float) : Void;
	function scaleMatrix(p1 : Float, p2 : Float) : Void;
	function setOrthographicProjection(p1 : Float, p2 : Float, p3 : Float, p4 : Float) : Void;
	function transformMatrix(p1 : starling.display.DisplayObject) : Void;
	function translateMatrix(p1 : Float, p2 : Float) : Void;
	static function assembleAgal(p1 : String, p2 : String, ?p3 : flash.display3D.Program3D) : flash.display3D.Program3D;
	static function clear(p1 : UInt = 0, p2 : Float = 0) : Void;
	static function getTextureLookupFlags(p1 : String, p2 : Bool, p3 : Bool = false, ?p4 : String) : String;
	static function setBlendFactors(p1 : Bool, ?p2 : String) : Void;
	static function setDefaultBlendFactors(p1 : Bool) : Void;
	static function transformMatrixForObject(p1 : flash.geom.Matrix, p2 : starling.display.DisplayObject) : Void;
}
