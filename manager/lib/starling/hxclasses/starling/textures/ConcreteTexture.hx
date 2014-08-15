package starling.textures;

extern class ConcreteTexture extends Texture {
	var onRestore : Dynamic;
	var optimizedForRenderTexture(default,never) : Bool;
	function new(p1 : flash.display3D.textures.TextureBase, p2 : String, p3 : Int, p4 : Int, p5 : Bool, p6 : Bool, p7 : Bool = false, p8 : Float = 1, p9 : Bool = false) : Void;
	function clear(p1 : UInt = 0, p2 : Float = 0) : Void;
	function createBase() : Void;
	function uploadAtfData(p1 : flash.utils.ByteArray, p2 : Int = 0, ?p3 : Dynamic) : Void;
	function uploadBitmap(p1 : flash.display.Bitmap) : Void;
	function uploadBitmapData(p1 : flash.display.BitmapData) : Void;
}
