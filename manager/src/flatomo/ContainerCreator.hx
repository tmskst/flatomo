package flatomo;
import starling.display.DisplayObject;

using Lambda;

class ContainerCreator {
	
	public static function isAlliedTo(source:flash.display.DisplayObject):Bool {
		return Std.is(source, flash.display.DisplayObjectContainer);
	}
	
	public static function create(source:flash.display.DisplayObjectContainer, sections:Array<Section>):Container {
		var movie:flash.display.MovieClip = cast(source, flash.display.MovieClip);
		var map = new Map<Int, Array<Layout>>();
		var displayObjects = new Array<DisplayObject>();
		
		for (frame in 1...(movie.totalFrames + 1)) {
			movie.gotoAndStop(frame);
			
			var layouts = new Array<Layout>();
			for (index in 0...movie.numChildren) {
				var source:flash.display.DisplayObject = movie.getChildAt(index);
				displayObjects.push(Creator.translate(source));
				layouts.push({ instanceName: source.name, libraryPath: /*FlatomoTools.fetchElement(source).libraryPath*/'', x: source.x, y: source.y });
			}
			map.set(frame, layouts);
		}
		
		var container:Container = new Container(displayObjects, map, sections);
		container.name = source.name;
		
		return container;
	}
	
}
