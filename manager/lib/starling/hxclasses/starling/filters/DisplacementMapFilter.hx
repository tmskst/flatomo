package starling.filters;

extern class DisplacementMapFilter extends FragmentFilter {
	var componentX : UInt;
	var componentY : UInt;
	var mapPoint : flash.geom.Point;
	var mapTexture : starling.textures.Texture;
	var repeat : Bool;
	var scaleX : Float;
	var scaleY : Float;
	function new(p1 : starling.textures.Texture, ?p2 : flash.geom.Point, p3 : UInt = 0, p4 : UInt = 0, p5 : Float = 0, p6 : Float = 0, p7 : Bool = false) : Void;
}
