package starling.textures;

extern class AtfData {
	var data(default,never) : flash.utils.ByteArray;
	var format(default,never) : String;
	var height(default,never) : Int;
	var numTextures(default,never) : Int;
	var width(default,never) : Int;
	function new(p1 : flash.utils.ByteArray) : Void;
	static function isAtfData(p1 : flash.utils.ByteArray) : Bool;
}
