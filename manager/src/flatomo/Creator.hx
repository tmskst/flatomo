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
	private static function translate(source:flash.display.DisplayObject):starling.display.DisplayObject {
		if (AnimationCreator.isAlliedTo(source)) {
			var sections:Array<Section> = FlatomoTools.fetchItem(source).sections;
			var animation = AnimationCreator.create(cast(source, flash.display.MovieClip), sections);
			Flatomo.juggler.add(animation);
			return animation;
		}
		if (ContainerCreator.isAlliedTo(source)) {
			var sections:Array<Section> = FlatomoTools.fetchItem(source).sections;
			var container = ContainerCreator.create(cast(source, flash.display.DisplayObjectContainer), sections);
			Flatomo.juggler.add(container);
			return container;
		}
		
		var bitmapData = Blitter.toBitmapData(source);
		return new Image(Texture.fromBitmapData(bitmapData));
	}
	
	
}
