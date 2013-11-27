package starling.textures;

extern class RenderTexture extends SubTexture {
	var isPersistent(default,never) : Bool;
	function new(p1 : Int, p2 : Int, p3 : Bool = true, p4 : Float = -1) : Void;
	function clear() : Void;
	function draw(p1 : starling.display.DisplayObject, ?p2 : flash.geom.Matrix, p3 : Float = 1, p4 : Int = 0) : Void;
	function drawBundled(p1 : flash.utils.Function, p2 : Int = 0) : Void;
}
