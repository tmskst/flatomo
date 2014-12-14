package flatomo.util;

import flatomo.GeometricTransform;
import jsfl.ElementType;
import jsfl.Instance;
import jsfl.Layer;
import jsfl.LayerType;
import jsfl.Matrix;
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
				if (frame.elements.empty()) {
					return null;
				}
				var matrix:Matrix = frame.elements[0].matrix;
				var transform = new GeometricTransform(
					matrix.a, matrix.b,
					matrix.c, matrix.d,
					matrix.tx, matrix.ty
				);
				return transform;
			}));
		}
		
		return markers;
	}
	
}
