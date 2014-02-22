package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flatomo.Creator.Meta;

class Flatomo {
	
	public static function createTextureAtlas(config:DisplayObjectContainer, classes:Array<Class<DisplayObject>>):{ atlas:BitmapData, layout:Xml, meta:Map<String, Meta> } {
		var library = FlatomoTools.fetchLibrary(config);
		var source = Creator.create(library, classes);
		var atlas = AtlasGenerator.generate(source.images);
		return { atlas:atlas.atlas, layout:atlas.layout, meta: source.meta };
	}
	
}
