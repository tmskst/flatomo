package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.xml.XML;
import flatomo.Meta;

class Flatomo {
	
	public static function createTextureAtlas(config:DisplayObjectContainer, classes:Array<Class<DisplayObject>>):{image:BitmapData, layout:XML, metaData:Map<String, Meta>} {
		var library = FlatomoTools.fetchLibrary(config);
		var source = Creator.create(library, classes);
		var atlas = AtlasGenerator.generate(source.images);
		var xml = new XML(atlas.layout.toString());
		return { image:atlas.image, layout: xml, metaData: source.meta };
	}
	
}
