package starling.text;

extern class BitmapChar {
	var charID(default,never) : Int;
	var height(default,never) : Float;
	var texture(default,never) : starling.textures.Texture;
	var width(default,never) : Float;
	var xAdvance(default,never) : Float;
	var xOffset(default,never) : Float;
	var yOffset(default,never) : Float;
	function new(p1 : Int, p2 : starling.textures.Texture, p3 : Float, p4 : Float, p5 : Float) : Void;
	function addKerning(p1 : Int, p2 : Float) : Void;
	function createImage() : starling.display.Image;
	function getKerning(p1 : Int) : Float;
}
