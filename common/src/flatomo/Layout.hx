package flatomo;

/** 表示オブジェクトの配置情報 */
class Layout {
	/** 深度 */
	public var depth(default, null):Int;
	/** 幾何変換行列 */
	public var transform(default, null):GeometricTransform;
	
	public function new(depth:Int, transform:GeometricTransform) {
		this.depth = depth;
		this.transform = transform;
	}
	
}
