package starling.textures;

extern class Texture {
	var base(default,never) : flash.display3D.textures.TextureBase;
	var format(default,never) : String;
	var frame(default,never) : flash.geom.Rectangle;
	var height(default,never) : Float;
	var mipMapping(default,never) : Bool;
	var nativeHeight(default,never) : Float;
	var nativeWidth(default,never) : Float;
	var premultipliedAlpha(default,never) : Bool;
	var repeat : Bool;
	var root(default,never) : ConcreteTexture;
	var scale(default,never) : Float;
	var width(default,never) : Float;
	function new() : Void;
	function adjustTexCoords(p1 : flash.Vector<Float>, p2 : Int = 0, p3 : Int = 0, p4 : Int = -1) : Void;
	function adjustVertexData(p1 : starling.utils.VertexData, p2 : Int, p3 : Int) : Void;
	function dispose() : Void;
	static function empty(p1 : Float, p2 : Float, p3 : Bool = true, p4 : Bool = true, p5 : Bool = false, p6 : Float = -1, ?p7 : String) : Texture;
	static function fromAtfData(p1 : flash.utils.ByteArray, p2 : Float = 1, p3 : Bool = true, ?p4 : Dynamic) : Texture;
	static function fromBitmap(p1 : flash.display.Bitmap, p2 : Bool = true, p3 : Bool = false, p4 : Float = 1, ?p5 : String) : Texture;
	static function fromBitmapData(p1 : flash.display.BitmapData, p2 : Bool = true, p3 : Bool = false, p4 : Float = 1, ?p5 : String) : Texture;
	static function fromColor(p1 : Float, p2 : Float, p3 : UInt = 0xFFFFFFFF, p4 : Bool = false, p5 : Float = -1, ?p6 : String) : Texture;
	static function fromEmbeddedAsset(p1 : Class<Dynamic>, p2 : Bool = true, p3 : Bool = false, p4 : Float = 1, ?p5 : String) : Texture;
	static function fromTexture(p1 : Texture, ?p2 : flash.geom.Rectangle, ?p3 : flash.geom.Rectangle) : Texture;
}
