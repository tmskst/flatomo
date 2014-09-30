package ;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import haxe.io.Bytes;
import haxe.io.BytesData;

class FileUtil {
	
	@:noUsing
	public static function getContent(file:File):String {
		var fs = new FileStream();
		fs.open(file, FileMode.READ);
		
		var utfBytes = fs.readUTFBytes(fs.bytesAvailable);
		fs.close();
		return utfBytes;
	}
	
	@:noUsing
	public static function getBytes(file:File):Bytes {
		var fs = new FileStream();
		fs.open(file, FileMode.READ);
		
		var bytesData = new BytesData();
		fs.readBytes(bytesData, 0, fs.bytesAvailable);
		fs.close();
		
		return Bytes.ofData(bytesData);
	}
	
}
