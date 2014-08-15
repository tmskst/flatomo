package starling.utils;

extern class RectangleUtil {
	function new() : Void;
	static function fit(p1 : flash.geom.Rectangle, p2 : flash.geom.Rectangle, ?p3 : String, p4 : Bool = false, ?p5 : flash.geom.Rectangle) : flash.geom.Rectangle;
	static function getBounds(p1 : flash.geom.Rectangle, p2 : flash.geom.Matrix, ?p3 : flash.geom.Rectangle) : flash.geom.Rectangle;
	static function intersect(p1 : flash.geom.Rectangle, p2 : flash.geom.Rectangle, ?p3 : flash.geom.Rectangle) : flash.geom.Rectangle;
	static function normalize(p1 : flash.geom.Rectangle) : Void;
}
