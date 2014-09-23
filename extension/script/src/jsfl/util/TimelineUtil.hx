package jsfl.util;

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
	
}
