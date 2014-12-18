package jsfl.util;

class UriUtil {
	
	public static function toAbsolutePath(baseUri:String, relativePath:String):String {
		var bs:Array<String> = baseUri.split('/');
		var rs:Array<String> = relativePath.split('/');
		
		while (rs[0] == '..') {
			bs.pop();
			rs.shift();
		}
		
		return bs.join('/') + '/' + rs.join('/');
	}
	
	public static function toRelativePath(sourceUri:String, targetUri:String):String {
		var ss:Array<String> = sourceUri.split('/');
		var ts:Array<String> = targetUri.split('/');
		
		while (ss[0] == ts[0]) {
			ss.shift();
			ts.shift();
		}
		
		return [for (i in 0...ss.length) '../'].join('') + ts.join('/');
	}

}
