package flatomo;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Rectangle;

class Blitter {
	
	// 表示オブジェクトをビットマップに変換
	public static function toBitmap(source:DisplayObject, ?bounds:Rectangle = null):Bitmap {
		return new Bitmap(toBitmapData(source, bounds));
	}
	
	// 表示オブジェクトをビットマップデータに変換
	public static function toBitmapData(source:DisplayObject, ?bounds:Rectangle = null):BitmapData {
		if (bounds == null) {
			bounds = source.getBounds(source);
		}
		
		var width:Int = Std.int(bounds.width);
		var height:Int = Std.int(bounds.height);
		
		var bitmapData:BitmapData = new BitmapData(width, height, true, 0x0000FFFF);
		bitmapData.drawWithQuality(source);
		return bitmapData;
	}
	
}