package flatomo.util;

import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.xml.XML;
import flatomo.RawTextureAtlas;
import haxe.ds.StringMap;
import haxe.Unserializer;

private typedef EmbedAssetKit = {
	atlases:Array<EmbedTextureAtlas>,
	structures:Array<Class<ByteArray>>
};

class AssetKitUtil {
	@:noUsing
	public static function fromEmbedAssets(assets:EmbedAssetKit):AssetKit {
		var rawTextureAtlases = new Array<RawTextureAtlas>();
		for (lowAtlas in assets.atlases) {
			var rawTextureAtlas:RawTextureAtlas = switch (lowAtlas) {
				case EmbedTextureAtlas.BitmapData(image, layout) :
					RawTextureAtlas.BitmapData(
						Type.createInstance(image, [0, 0]),
						new XML(Type.createInstance(layout, []).toString())
					);
				case EmbedTextureAtlas.Atf(image, layout) :
					RawTextureAtlas.Atf(
						Type.createInstance(image, []),
						new XML(Type.createInstance(layout, []).toString())
					);
			}
			rawTextureAtlases.push(rawTextureAtlas);
		}
		
		var structures = new Array<StringMap<Structure>>();
		for (lowPosture in assets.structures) {
			structures.push(Unserializer.run(Type.createInstance(lowPosture, []).toString()));
		}
		
		return {
			atlases: rawTextureAtlases,
			structures: StringMapUtil.unite(structures),
		};
	}
	
}
