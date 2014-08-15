package starling.display;

extern class Button extends DisplayObjectContainer {
	var alphaWhenDisabled : Float;
	var downState : starling.textures.Texture;
	var enabled : Bool;
	var fontBold : Bool;
	var fontColor : UInt;
	var fontName : String;
	var fontSize : Float;
	var scaleWhenDown : Float;
	var text : String;
	var textBounds : flash.geom.Rectangle;
	var textHAlign : String;
	var textVAlign : String;
	var upState : starling.textures.Texture;
	function new(p1 : starling.textures.Texture, ?p2 : String, ?p3 : starling.textures.Texture) : Void;
}
