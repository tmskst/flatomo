package starling.utils;

extern class MatrixUtil {
	function new() : Void;
	static function convertTo3D(p1 : flash.geom.Matrix, ?p2 : flash.geom.Matrix3D) : flash.geom.Matrix3D;
	static function prependMatrix(p1 : flash.geom.Matrix, p2 : flash.geom.Matrix) : Void;
	static function prependRotation(p1 : flash.geom.Matrix, p2 : Float) : Void;
	static function prependScale(p1 : flash.geom.Matrix, p2 : Float, p3 : Float) : Void;
	static function prependSkew(p1 : flash.geom.Matrix, p2 : Float, p3 : Float) : Void;
	static function prependTranslation(p1 : flash.geom.Matrix, p2 : Float, p3 : Float) : Void;
	static function skew(p1 : flash.geom.Matrix, p2 : Float, p3 : Float) : Void;
	static function transformCoords(p1 : flash.geom.Matrix, p2 : Float, p3 : Float, ?p4 : flash.geom.Point) : flash.geom.Point;
}
