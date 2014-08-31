package flatomo;

class LogicClipVo {
	
	public function new(
		allSections:Map<Linkage, Array<Section>>,
		allMarkers:Map<Linkage, Map<LayerName, Map<Int, Marker>>>
	) {
		this.allSections = allSections;
		this.allMarkers = allMarkers;
	}
	
	private var allSections:Map<Linkage, Array<Section>>;
	private var allMarkers:Map<Linkage, Map<LayerName, Map<Int, Marker>>>;
	
	public function getLogicClip(key:Linkage):LogicClip {
		var sections:Array<Section> = allSections.get(key);
		var markers:Map<LayerName, Map<Int, Marker>> = allMarkers.get(key);
		return new LogicClip(sections, markers);
	}
	
}
