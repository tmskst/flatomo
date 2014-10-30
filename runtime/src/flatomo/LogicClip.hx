package flatomo;

import flatomo.display.Playhead;

class LogicClip {
	
	public var playhead(default, null):Playhead;
	private var markers:Map<String, Array<GeometricTransform>>;
	
	public function new(timeline:Timeline) {
		this.playhead = new Playhead(timeline.sections);
		this.markers = timeline.markers;
	}
	
	public function getCurrentMarker(layerName:String):GeometricTransform {
		if (!markers.exists(layerName)) { throw '存在しないレイヤー'; }
		
		var transforms:Array<GeometricTransform> = markers.get(layerName);
		return transforms[playhead.currentFrame - 1];
	}
	
}
