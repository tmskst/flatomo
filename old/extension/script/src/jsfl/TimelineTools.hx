package jsfl;

using Lambda;

class TimelineTools {
	
	public static function getUnionBounds(timeline:Timeline, includeHiddenLayers:Bool, includeGuideLayers:Bool):BoundingRectangle {
		if (includeGuideLayers) {
			for (layer in timeline.layers) {
				if (layer.layerType == LayerType.GUIDE) {
					layer.visible = false;
				}
			}
		}
		
		var unionBounds:BoundingRectangle = { left: .0, top: .0, right: .0, bottom: .0 };
		for (frameIndex in 0...timeline.frameCount) {
			var bounds = timeline.getBounds(frameIndex + 1, includeHiddenLayers);
			if (bounds != null) {
				unionBounds.left	= Math.min(unionBounds.left, bounds.left);
				unionBounds.top		= Math.min(unionBounds.top, bounds.top);
				unionBounds.right	= Math.max(unionBounds.right, bounds.right);
				unionBounds.bottom	= Math.max(unionBounds.bottom, bounds.bottom);
			}
		}
		return unionBounds;
	}
	
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
