package flatomo.util;

import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.xml.XML;
import flatomo.translator.RawTextureAtlas;
import haxe.ds.StringMap;
import haxe.Unserializer;

private typedef EmbedAssetKit = {
	atlases:Array<{ image:Class<BitmapData>, layout:Class<ByteArray> }>,
	postures:Array<Class<ByteArray>>
};

class AssetKitUtil {
	@:noUsing
	public static function fromEmbedAssets(assets:EmbedAssetKit):AssetKit {
		var rawTextureAtlases = new Array<RawTextureAtlas>();
		for (lowAtlas in assets.atlases) {
			rawTextureAtlases.push( {
				image: Type.createInstance(lowAtlas.image, [0, 0]),
				layout: new XML(Type.createInstance(lowAtlas.layout, []).toString()),
			});
		}
		
		var postures = new Array<StringMap<Posture>>();
		for (lowPosture in assets.postures) {
			postures.push(Unserializer.run(Type.createInstance(lowPosture, []).toString()));
		}
		
		return {
			atlases: rawTextureAtlases,
			postures: StringMapUtil.unite(postures),
		};
	}
	
}
