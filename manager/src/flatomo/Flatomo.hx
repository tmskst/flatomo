package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import starling.textures.TextureAtlas;

class Flatomo {
	
	public function new(config:flash.display.DisplayObjectContainer):Void {
		this.library = FlatomoTools.fetchLibrary(config);
		this.sources = new Map<String, Source>();
	}
	
	public var library(default, null):Map<String, FlatomoItem>;
	public var sources(default, null):Map<String, Source>;
	
	public function create(classes:Array<Class<flash.display.DisplayObject>>):TextureAtlas {
		for (clazz in classes) {
			Creator.translate(Type.createInstance(clazz, []), "root", this);
		}
		
		var mints:Array<{ name:String, bitmapData:BitmapData }> = new Array<{ name:String, bitmapData:BitmapData }>();
		for (key in sources.keys()) {
			var source = sources.get(key);
			switch (source) {
				case Source.Animation(_name, _textures, sections) : 
					for (i in 0...(_textures.length)) {
						var index = ("00000" + Std.string(i)).substr(-5);
						mints.push( { name: '${key} ${index}', bitmapData : _textures[i] } );
					}
				case Source.Container(_name, _displayObjects, _layouts, _sections) :
				case Source.Texture(_name, _texture) : 
					mints.push( { name: '${key}', bitmapData : _texture } );
			}
		}
		
		return AtlasGenerator.generate(mints);
	}
	
}
