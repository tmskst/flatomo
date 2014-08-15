package starling.textures;

extern class SubTexture extends Texture {
	var clipping(default,never) : flash.geom.Rectangle;
	var ownsParent(default,never) : Bool;
	var parent(default,never) : Texture;
	var rotated(default,never) : Bool;
	var transformationMatrix(default,never) : flash.geom.Matrix;
	function new(p1 : Texture, p2 : flash.geom.Rectangle, p3 : Bool = false, ?p4 : flash.geom.Rectangle, p5 : Bool = false) : Void;
}
