package flatomo;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

class Creator {
	
	public static function translate(source:flash.display.DisplayObject):starling.display.DisplayObject {
		if (source == null) throw "NULL";
		
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
