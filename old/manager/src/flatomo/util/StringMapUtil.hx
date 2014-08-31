package flatomo.util;

import haxe.ds.StringMap;

class StringMapUtil {
	@:noUsing
	public static function unite<V>(maps:Array<StringMap<V>>):StringMap<V> {
		var union = new StringMap<V>();
		for (map in maps) {
			for (key in map.keys()) {
				if (union.exists(key)) {
					trace('重複するキー : ${key}');
				}
				union.set(key, map.get(key));
			}
		}
		return union;
	}
}
