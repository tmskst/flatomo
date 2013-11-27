package starling.display;

extern class MovieClip extends Image implements starling.animation.IAnimatable {
	var currentFrame : Int;
	var currentTime(default,never) : Float;
	var fps : Float;
	var isComplete(default,never) : Bool;
	var isPlaying(default,never) : Bool;
	var loop : Bool;
	var numFrames(default,never) : Int;
	var totalTime(default,never) : Float;
	function new(p1 : flash.Vector<starling.textures.Texture>, p2 : Float = 12) : Void;
	function addFrame(p1 : starling.textures.Texture, ?p2 : flash.media.Sound, p3 : Float = -1) : Void;
	function addFrameAt(p1 : Int, p2 : starling.textures.Texture, ?p3 : flash.media.Sound, p4 : Float = -1) : Void;
	function advanceTime(p1 : Float) : Void;
	function getFrameDuration(p1 : Int) : Float;
	function getFrameSound(p1 : Int) : flash.media.Sound;
	function getFrameTexture(p1 : Int) : starling.textures.Texture;
	function pause() : Void;
	function play() : Void;
	function removeFrameAt(p1 : Int) : Void;
	function setFrameDuration(p1 : Int, p2 : Float) : Void;
	function setFrameSound(p1 : Int, p2 : flash.media.Sound) : Void;
	function setFrameTexture(p1 : Int, p2 : starling.textures.Texture) : Void;
	function stop() : Void;
}
