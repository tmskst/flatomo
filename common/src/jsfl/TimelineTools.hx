package jsfl;

class TimelineTools {
	
	/**
	 * @scan Timelineに存在するすべてのElement
	 */
	public static function scan_allElement(timeline:Timeline, func:Element -> Void):Void {
		for (layer in timeline.layers) {
			if (layer.layerType == LayerType.GUIDE) { continue; }
			for (frame in layer.frames) {
				for (element in frame.elements) {
					func(element);
				}
			}
		}
	}
	
	/**
	 * @scan Timelineに存在するすべてのInstance
	 */
	public static function scan_allInstance(timeline:Timeline, func:Instance -> Void):Void {
		scan_allElement(timeline, function (element:Element) {
			if (Std.is(element, Instance)) {
				func(cast(element, Instance));
			}
		});
	}
	
}
