package flatomo;

/** jsfl.Timelineから抽出できる拡張タイムライン */
class Timeline {
	/** セクション情報 */
	public var sections(default, null):Array<Section>;
	/** マーカー情報 */
	public var markers(default, null):Map<String, Array<GeometricTransform>>;
	
	public function new(sections:Array<Section>, markers:Map<String, Array<GeometricTransform>>) {
		this.sections = sections;
		this.markers = markers;
	}
	
}
