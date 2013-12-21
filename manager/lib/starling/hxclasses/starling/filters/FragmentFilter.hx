package starling.filters;

extern class FragmentFilter {
	var baseTextureID : Int;
	var isCached(default,never) : Bool;
	var marginX : Float;
	var marginY : Float;
	var mode : String;
	var mvpConstantID : Int;
	var numPasses : Int;
	var offsetX : Float;
	var offsetY : Float;
	var resolution : Float;
	var texCoordsAtID : Int;
	var vertexPosAtID : Int;
	function new(p1 : Int = 1, p2 : Float = 1) : Void;
	function cache() : Void;
	function clearCache() : Void;
	function compile(p1 : starling.display.DisplayObject) : starling.display.QuadBatch;
	function dispose() : Void;
	function render(p1 : starling.display.DisplayObject, p2 : starling.core.RenderSupport, p3 : Float) : Void;
}
