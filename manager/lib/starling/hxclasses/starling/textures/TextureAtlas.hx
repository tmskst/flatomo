package starling.textures;

extern class TextureAtlas {
	var texture(default,never) : Texture;
	function new(p1 : Texture, ?p2 : flash.xml.XML) : Void;
	function addRegion(p1 : String, p2 : flash.geom.Rectangle, ?p3 : flash.geom.Rectangle, p4 : Bool = false) : Void;
	function dispose() : Void;
	function getFrame(p1 : String) : flash.geom.Rectangle;
	function getNames(?p1 : String, ?p2 : flash.Vector<String>) : flash.Vector<String>;
	function getRegion(p1 : String) : flash.geom.Rectangle;
	function getRotation(p1 : String) : Bool;
	function getTexture(p1 : String) : Texture;
	function getTextures(?p1 : String, ?p2 : flash.Vector<Texture>) : flash.Vector<Texture>;
	function removeRegion(p1 : String) : Void;
}
