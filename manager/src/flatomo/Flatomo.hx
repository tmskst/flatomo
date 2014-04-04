package flatomo;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.xml.XML;
import flatomo.Meta;

class Flatomo {
	
	/**
	 * ライブラリと解析する（表示オブジェクトを親に持つ）クラスから再構築するために必要なアセットを生成する
	 * @param	library ライブラリ
	 * @param	classes 解析する（表示オブジェクトを親に持つ）クラスの列挙
	 */
	public static function createTextureAtlas(library:FlatomoLibrary, classes:Array<Class<DisplayObject>>):{ atlases:Array<RawTextureAtlas>, metaData:Map<String, Meta>} {
		var source = Creator.create(library, classes);
		var atlases = AtlasGenerator.generate(source.images);
		return { atlases: atlases, metaData: source.meta };
	}
	
}
