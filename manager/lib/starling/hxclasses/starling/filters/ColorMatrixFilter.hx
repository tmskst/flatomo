package starling.filters;

extern class ColorMatrixFilter extends FragmentFilter {
	var matrix : flash.Vector<Float>;
	function new(?p1 : flash.Vector<Float>) : Void;
	function adjustBrightness(p1 : Float) : Void;
	function adjustContrast(p1 : Float) : Void;
	function adjustHue(p1 : Float) : Void;
	function adjustSaturation(p1 : Float) : Void;
	function concat(p1 : flash.Vector<Float>) : Void;
	function invert() : Void;
	function reset() : Void;
}
