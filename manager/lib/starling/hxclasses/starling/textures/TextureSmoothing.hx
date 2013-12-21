package starling.textures;

extern class TextureSmoothing {
	function new() : Void;
	static var BILINEAR : String;
	static var NONE : String;
	static var TRILINEAR : String;
	static function isValid(p1 : String) : Bool;
}
