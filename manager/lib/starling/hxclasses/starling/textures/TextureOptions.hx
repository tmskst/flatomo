package starling.textures;

extern class TextureOptions {
	var format : String;
	var mipMapping : Bool;
	var onReady : Dynamic;
	var optimizeForRenderToTexture : Bool;
	var repeat : Bool;
	var scale : Float;
	function new(p1 : Float = 1, p2 : Bool = false, ?p3 : String, p4 : Bool = false) : Void;
	function clone() : TextureOptions;
}
