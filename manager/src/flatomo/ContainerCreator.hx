package flatomo;
import starling.display.DisplayObject;

class ContainerCreator {
	
	public static function isAlliedTo(source:flash.display.DisplayObject):Bool {
		return Std.is(source, flash.display.DisplayObjectContainer);
	}
	
	public static function create(source:flash.display.DisplayObjectContainer, KEYFRAMES:Array<KeyFrame>):Container {
		
		var ELEMENTS = new Map<String, DisplayObject>();
		
		for (keyFrame in KEYFRAMES) {
			if (Std.is(source, flash.display.MovieClip)) {
				cast(source, flash.display.MovieClip).gotoAndStop(keyFrame.start);
			}
			
			for (element in keyFrame.elements) {
				var child:flash.display.DisplayObject = source.getChildByName(element.name);
				if (!ELEMENTS.exists(element.name)) {
					ELEMENTS.set(element.name, Creator.translate(child));
				}
			}
		}
		
		return new Container(KEYFRAMES, ELEMENTS);
	}
	
}