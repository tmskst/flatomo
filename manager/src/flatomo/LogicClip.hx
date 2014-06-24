package flatomo;

import flatomo.display.Playhead;

class LogicClip {
	
	public function new(sections:Array<Section>, markers:Map<LayerName, Map<Int, Marker>>) {
		this.playhead = new Playhead(sections);
		this.markers = markers;
	}
	
	public var playhead(default, null):Playhead;
	private var markers:Map<LayerName, Map<Int, Marker>>;
	
	public function getCurrentMarker(layerName:LayerName):Marker {
		if (markers.exists(layerName)) {
			var layerMarkers:Map<Int, Marker> = markers.get(layerName);
			if (layerMarkers.exists(playhead.currentFrame - 1)) {
				return layerMarkers.get(playhead.currentFrame - 1);
			}
		}
		throw '存在しないレイヤー${layerName}, ${markers}';
	}

}
