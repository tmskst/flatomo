package flatomo;

import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;

class Creator {
	
	public static function translate(source:flash.display.DisplayObject):starling.display.DisplayObject {
		if (source == null) throw "NULL";
		
		if (AnimationCreator.isAlliedTo(source)) {
			var sections = [ { name: "", kind: SectionKind.Loop, begin: 1, end: 30 } ];
			var animation = AnimationCreator.create(cast(source, flash.display.MovieClip), sections);
			Flatomo.juggler.add(animation);
			return animation;
		}
		if (ContainerCreator.isAlliedTo(source)) {
			var KEYFRAMES:Array<KeyFrame> = [
				{ start: 1, end:  8, elements: [ { name: "a", layout: { x:  1, y: 1 }} ] },
				{ start: 9, end: 20, elements: [  ] }
			];
			var container = ContainerCreator.create(cast(source, flash.display.DisplayObjectContainer), KEYFRAMES);
			Flatomo.juggler.add(container);
			return container;
		}
		
		var bitmapData = Blitter.toBitmapData(source);
		return new Image(Texture.fromBitmapData(bitmapData));
	}
	
	
}