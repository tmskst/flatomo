package flatomo;

import flash.display.DisplayObject;
import flatomo.AssetKit;
import flatomo.translator.AtlasGenerator;
import flatomo.translator.Translator;

class Flatomo {
	
	/**
	 * ライブラリと解析する（表示オブジェクトを親に持つ）クラスから再構築するために必要なアセットを生成する
	 * @param	library ライブラリ
	 * @param	classes 解析する（表示オブジェクトを親に持つ）クラスの列挙
	 */
	public static function createTextureAtlas(library:FlatomoLibrary, classes:Array<Class<DisplayObject>>):AssetKit {
		var source = Translator.create(library, classes);
		var atlases = AtlasGenerator.generate(source.images);
		return { atlases: atlases, postures: source.postures };
	}
	
}
