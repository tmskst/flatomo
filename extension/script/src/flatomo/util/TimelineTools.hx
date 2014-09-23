package flatomo.util;

import jsfl.ElementType;
import jsfl.Instance;
import jsfl.Layer;
import jsfl.LayerType;
import jsfl.Timeline;

using Lambda;

class TimelineTools {
	
	public static function getMarkers(timeline:Timeline):Map<String, Array<GeometricTransform>> {
		
		var markerLayers = timeline.layers.filter(function (layer) {
			return layer.layerType.equals(LayerType.GUIDE) &&
			       StringTools.startsWith(layer.name, 'marker_');
		});
		
		var markers = new Map<String, Array<GeometricTransform>>();
		for (markerLayer in markerLayers) {
			markers.set(markerLayer.name, markerLayer.frames.map(function (frame) {
				return untyped if (frame.elements.empty()) null else frame.elements[0].matrix;
			}));
		}
		
		return markers;
	}
	
}
