package flatomo;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class Blitter {
	
	/**
	 * 表示オブジェクトをビットマップに変換する。
	 * @param	source ビットマップに変換する表示オブジェクト。
	 * @param	?bounds 変換後のビットマップの大きさ。指定がない場合は source#getBounds が使われる。
	 * @return 生成したビットマップ。
	 */
	public static function toBitmap(source:DisplayObject, ?bounds:Rectangle = null):Bitmap {
		return new Bitmap(toBitmapData(source, bounds));
	}
	
	/**
	 * 表示オブジェクトをビットマップデータに変換する。
	 * @param	source ビットマップデータに変換する表示オブジェクト。
	 * @param	?bounds 変換後のビットマップの大きさ。指定がない場合は source#getBounds が使われる。
	 * @return 生成したビットマップデータ。
	 */
	public static function toBitmapData(source:DisplayObject, ?bounds:Rectangle = null):BitmapData {
		// TODO : この実装は完全ではありません。Shapeオブジェクト(JSFL)に対して意図した結果が得られないことがあります。
		if (bounds == null) {
			bounds = source.getBounds(source);
		}
		
		var width:Int = Std.int(bounds.width);
		var height:Int = Std.int(bounds.height);
		
		if (width == 0 || height == 0) {
			return new BitmapData(1, 1, true, 0x00000000);
		}
		
		var bitmapData:BitmapData = new BitmapData(width, height, true, 0x0000FFFF);
		bitmapData.drawWithQuality(source, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
		return bitmapData;
	}
	
}
