package flatomo.util;
import flash.xml.XML;
import flatomo.AssetKit;
import haxe.Unserializer;

class EmbedAssetUtil {
	public static function getAssetKit(keys:Array<String>):AssetKit {
		
		var atlases = new Array<RawTextureAtlas>();
		var structures = new Map<String, Structure>();
		
		for (key in keys) {
			atlases.push(RawTextureAtlas.BitmapData(
				Type.createInstance(Type.resolveClass(key + 'Texture'), []),
				new XML(Type.createInstance(Type.resolveClass(key + 'Xml'), []))
			));
			structures = Unserializer.run(Type.createInstance(Type.resolveClass(key + 'Posture'), []));
		}
		return { atlases: atlases, structures: structures };
	}
	
	
}
