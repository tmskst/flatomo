package flatomo;

import flatomo.display.Playhead;

class LogicClip {
	
	public var playhead:Playhead;
	private var markers:Map<String, Array<GeometricTransform>>;
	
	public function new(timeline:Timeline) {
		this.playhead = new Playhead(timeline.sections);
		this.markers = timeline.markers;
	}
	
	/*
	public function getCurrentMarker(layerName:LayerName):Marker {
		if (markers.exists(layerName)) {
			var layerMarkers:Map<Int, Marker> = markers.get(layerName);
			if (layerMarkers.exists(playhead.currentFrame - 1)) {
				return layerMarkers.get(playhead.currentFrame - 1);
			}
		}
		throw '存在しないレイヤー${layerName}, ${markers}';
	}
	*/
}
