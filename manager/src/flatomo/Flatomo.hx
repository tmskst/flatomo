package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flatomo.Creator.Meta;
import starling.textures.TextureAtlas;

class Flatomo {
	
	public static function createTextureAtlas(config:DisplayObjectContainer, classes:Array<Class<DisplayObject>>):TextureAtlas {
		var library = FlatomoTools.fetchLibrary(config);
		var foobar = Creator.create(library, classes);
		return AtlasGenerator.generate(foobar.images);
	}
	
}
