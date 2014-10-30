package flatomo;

/** jsfl.Timelineから抽出できる拡張タイムライン */
typedef Timeline = {
	/** セクション情報 */
	sections:Array<Section>,
	/** マーカー情報 */
	markers:Map<String, Array<GeometricTransform>>,
}
