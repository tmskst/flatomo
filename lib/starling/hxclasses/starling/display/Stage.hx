package starling.display;

extern class Stage extends DisplayObjectContainer {
	var color : UInt;
	var stageHeight : Int;
	var stageWidth : Int;
	function new(p1 : Int, p2 : Int, p3 : UInt = 0) : Void;
	function addEnterFrameListener(p1 : DisplayObject) : Void;
	function advanceTime(p1 : Float) : Void;
	function drawToBitmapData(?p1 : flash.display.BitmapData) : flash.display.BitmapData;
	function removeEnterFrameListener(p1 : DisplayObject) : Void;
}
