package starling.core;

extern class StatsDisplay extends starling.display.Sprite {
	var drawCount : Int;
	var fps : Float;
	var memory : Float;
	function new() : Void;
	function update() : Void;
}
