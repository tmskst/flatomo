package starling.filters;

extern class BlurFilter extends FragmentFilter {
	var blurX : Float;
	var blurY : Float;
	function new(p1 : Float = 1, p2 : Float = 1, p3 : Float = 1) : Void;
	function setUniformColor(p1 : Bool, p2 : UInt = 0, p3 : Float = 1) : Void;
	static function createDropShadow(p1 : Float = 4, p2 : Float = 0.785, p3 : UInt = 0, p4 : Float = 0.5, p5 : Float = 1, p6 : Float = 0.5) : BlurFilter;
	static function createGlow(p1 : UInt = 16776960, p2 : Float = 1, p3 : Float = 1, p4 : Float = 0.5) : BlurFilter;
}
