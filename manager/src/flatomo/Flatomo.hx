package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.xml.XML;
import flatomo.Meta;

class Flatomo {
	
	public static function createTextureAtlas(config:DisplayObjectContainer, classes:Array<Class<DisplayObject>>):{ atlases:Array<{image:BitmapData, layout:XML}>, metaData:Map<String, Meta>} {
		var library = FlatomoTools.fetchLibrary(config);
		var source = Creator.create(library, classes);
		var atlases = AtlasGenerator.generate(source.images);
		return { atlases: atlases, metaData: source.meta };
	}
	
}
