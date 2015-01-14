package flatomo;

class Bounds {
	
	public var left(default, null):Float;
	public var top(default, null):Float;
	public var right(default, null):Float;
	public var bottom(default, null):Float;
	
	public function new(left:Float, top:Float, right:Float, bottom:Float):Void {
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}
	
}
