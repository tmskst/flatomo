package flatomo;

/** 幾何変換行列 */
class GeometricTransform {
	public var a(default, null):Float;
	public var b(default, null):Float;
	public var c(default, null):Float;
	public var d(default, null):Float;
	public var tx(default, null):Float;
	public var ty(default, null):Float;
	
	public function new(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.tx = tx;
		this.ty = ty;
	}
}
