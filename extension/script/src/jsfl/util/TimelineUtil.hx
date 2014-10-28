package jsfl.util;

import jsfl.BoundingRectangle;
import jsfl.ElementType;
import jsfl.Instance;
import jsfl.Layer;
import jsfl.LayerType;
import jsfl.Timeline;

using Lambda;

class TimelineUtil {
	
	/** タイムライン中のすべてのインスタンスを取得する */
	public static function instances(timeline:Timeline):Array<Instance> {
		var instances = new Array<Instance>();
		for (layer in normalLayers(timeline)) {
			for (frame in layer.frames) {
				instances = instances.concat(untyped frame.elements.filter(function (element) return element.elementType.equals(ElementType.INSTANCE)));
			}
		}
		return instances;
	}
	
	/** タイムライン中の'NORMAL'レイヤーを取得する */
	public static function normalLayers(timeline:Timeline):Array<Layer> {
		return timeline.layers.filter(function (layer) return layer.layerType.equals(LayerType.NORMAL));
	}
	
	public static function getUnionBounds(timeline:Timeline):BoundingRectangle {
		var unionBounds:BoundingRectangle = { left: 0, top: 0, right: 0, bottom: 0 };
		for (frame in 0...timeline.frameCount) {
			var bounds:BoundingRectangle = timeline.getBounds(frame + 1 , false);
			unionBounds.left   = Math.min(unionBounds.left, bounds.left);
			unionBounds.top    = Math.min(unionBounds.top, bounds.top);
			unionBounds.right  = Math.max(unionBounds.right, bounds.right);
			unionBounds.bottom = Math.max(unionBounds.bottom, bounds.bottom);
		}
		return unionBounds;
	}
	
}
