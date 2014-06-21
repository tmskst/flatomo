package flatomo;

import flatomo.display.Playhead;

class LogicClip {
	
	public function new(sections:Array<Section>, markers:Map<LayerName, Map<Int, Marker>>) {
		this.playhead = new Playhead(sections);
		this.markers = markers;
	}
	
	private var playhead:Playhead;
	private var markers:Map<LayerName, Map<Int, Marker>>;
	
	public function currentMarkers(layerName:LayerName):Marker {
		if (markers.exists(layerName)) {
			var layerMarkers:Map<Int, Marker> = markers.get(layerName);
			if (layerMarkers.exists(playhead.currentFrame)) {
				return layerMarkers.get(playhead.currentFrame);
			}
		}
		return null;
	}

}
