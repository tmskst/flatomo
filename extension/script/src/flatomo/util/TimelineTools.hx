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
	
	public static function getMarkers(timeline:Timeline):Map<String, Array<Marker>> {
		
		var markerLayers = timeline.layers.filter(function (layer) {
			return layer.layerType.equals(LayerType.GUIDE) &&
			       StringTools.startsWith(layer.name, 'marker_');
		});
		
		var markers = new Map<String, Array<Marker>>();
		for (markerLayer in markerLayers) {
			markers.set(markerLayer.name, markerLayer.frames.map(function (frame) {
				return untyped if (frame.elements.empty()) null else frame.elements[0].matrix;
			}));
		}
		
		return markers;
	}
	
}
