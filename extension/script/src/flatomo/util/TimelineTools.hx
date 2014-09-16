package flatomo.util;

import jsfl.Element;
import jsfl.ElementType;
import jsfl.Instance;
import jsfl.Layer;
import jsfl.LayerType;
import jsfl.Timeline;

using Lambda;

class TimelineTools {
	
	public static function instances(timeline:Timeline):Array<Instance> {
		var instances = new Array<Instance>();
		for (layer in TimelineTools.normalLayers(timeline)) {
			for (frame in layer.frames) {
				instances = instances.concat(untyped frame.elements.filter(function (element) return element.elementType.equals(ElementType.INSTANCE)));
			}
		}
		return instances;
	}
	
	public static function normalLayers(timeline:Timeline):Array<Layer> {
		return timeline.layers.filter(function (layer) return layer.layerType.equals(LayerType.NORMAL));
	}
	
}
