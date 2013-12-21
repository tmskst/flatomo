package com.adobe.utils;

extern class AGALMiniAssembler {
	var agalcode(default,never) : flash.utils.ByteArray;
	var error(default,never) : String;
	var verbose : Bool;
	function new(p1 : Bool = false) : Void;
	function assemble(p1 : String, p2 : String, p3 : UInt = 1, p4 : Bool = false) : flash.utils.ByteArray;
	function assemble2(p1 : flash.display3D.Context3D, p2 : UInt, p3 : String, p4 : String) : flash.display3D.Program3D;
}
