package starling.display;

extern class Image extends Quad {
	var smoothing : String;
	var texture : starling.textures.Texture;
	function new(p1 : starling.textures.Texture) : Void;
	function getTexCoords(p1 : Int, ?p2 : flash.geom.Point) : flash.geom.Point;
	function readjustSize() : Void;
	function setTexCoords(p1 : Int, p2 : flash.geom.Point) : Void;
	function setTexCoordsTo(p1 : Int, p2 : Float, p3 : Float) : Void;
	static function fromBitmap(p1 : flash.display.Bitmap, p2 : Bool = true, p3 : Float = 1) : Image;
}
