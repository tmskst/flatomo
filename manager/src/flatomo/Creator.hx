package flatomo;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

/**
 * flash.display.DisplayObject を starling.display.DisplayObject に変換する機能を提供する。
 */
@:allow(flatomo.Flatomo)
@:allow(flatomo.ContainerCreator)
class Creator {
	
	// TODO : 現在、テクスチャアトラスには対応していません。
	
	/**
	 * flash.display.DisplayObject を starling.display.DisplayObject に変換する。
	 * @param	source 変換元となる表示オブジェクト(flash.display)
	 * @return 変換後の表示オブジェクト(starling.display)
	 */
	private static function translate(source:flash.display.DisplayObject, path:String):starling.display.DisplayObject {
		if (AnimationCreator.isAlliedTo(source)) {
			var sections:Array<Section> = FlatomoTools.fetchItem(source).sections;
			var animation = AnimationCreator.create(cast(source, flash.display.MovieClip), sections);
			return animation;
		}
		if (ContainerCreator.isAlliedTo(source)) {
			var sections:Array<Section> = FlatomoTools.fetchItem(source).sections;
			var container = ContainerCreator.create(cast(source, flash.display.DisplayObjectContainer), sections, path);
			return container;
		}
		trace(path + "." +source.name);
		// アニメーションとコンテナに該当しない表示オブジェクトはテクスチャに変換される。
		var bitmapData = Blitter.toBitmapData(source);
		var image = new Image(Texture.fromBitmapData(bitmapData));
		image.name = source.name;
		
		return image;
	}
	
	
}
