package flatomo;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
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
	
	public static function getUnionBound(movie:MovieClip):Rectangle {
		var unionBounds = new Rectangle();
		for (frameIndex in 0...movie.totalFrames) {
			movie.gotoAndStop(frameIndex + 1);
			unionBounds = unionBounds.union(Blitter.getBounds(movie));
		}
		return unionBounds;
	}
	
	public static function getBounds(source:DisplayObject):Rectangle {
		var bounds = source.getBounds(source);
		return new Rectangle(Math.round(bounds.x), Math.round(bounds.y), Math.ceil(bounds.width), Math.ceil(bounds.height));
	}
	
	/**
	 * 表示オブジェクトをビットマップデータに変換する。
	 * @param	source ビットマップデータに変換する表示オブジェクト。
	 * @param	?bounds 変換後のビットマップの大きさ。指定がない場合は source#getBounds が使われる。
	 * @return 生成したビットマップデータ。
	 */
	public static function toBitmapData(source:DisplayObject, ?bounds:Rectangle = null):BitmapData {
		if (bounds == null) {
			bounds = Blitter.getBounds(source);
		}
		
		if (bounds.width == 0 || bounds.height == 0) {
			return new BitmapData(1, 1, true, 0x00000000);
		}
		
		var bitmapData:BitmapData = new BitmapData(cast bounds.width, cast bounds.height, true, 0x00000000);
		bitmapData.drawWithQuality(source, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
		return bitmapData;
	}
	
}
