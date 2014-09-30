package flatomo;

class Collection {
	
	public static function uniq<T>(xs:Array<T>):Iterable<T> {
		return [for (i in 0...xs.length) if (xs.indexOf(xs[i], i + 1) == -1) xs[i]];
	}
	
	public static function flatten<A>(xs:Iterable<A>):Array<Dynamic> {
		var rs = [];
		var f:Iterable<A> -> Void = null;
		f = function (es) {
			for (e in es) {
				if (Std.is(e, Array)) f(cast e) else rs.push(e);
			}
		};
		f(xs);
		return rs;
	}
	
	
}
