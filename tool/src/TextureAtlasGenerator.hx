package;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import haxe.ds.Option;

using Lambda;

/** どこにどう配置するか */
typedef Region = {
	x:Int,
	y:Int,
	width:Int,
	height:Int,
}

/** 敷き詰めるサブテクスチャ */
abstract SubTexture(Bitmap) from Bitmap to Bitmap {
	public var width(get, never):Int;
	private function get_width():Int {
		return this.bitmapData.width + 4;
	}
	
	public var height(get, never):Int;
	private function get_height():Int {
		return this.bitmapData.height + 4;
	}
}

typedef EmptyArea = {
	x:Int,
	y:Int,
	width:Int,
	height:Int,
}

typedef H = {
	size:Int,
	regions:Map<SubTexture, Region>,
}

// ------------------------------------------------------------------

class TextureAtlasGenerator {
	
	/** 充填 */
	public static function pack(numTextures:Int, subTextures:Array<SubTexture>):H {
		// サブテクスチャを高さ順にソート
		subTextures.sort(function (a, b) return b.height - a.height);
		
		for (textureSize in [128, 256, 512, 1024, 2048]) {
			var regions = new Map<SubTexture, Region>();
			
			// すべての空き領域
			// 初期状態はテクスチャすべてが空き領域
			var areas:Array<EmptyArea> = [{
				x : 0,
				y : 0,
				width : textureSize,
				height: textureSize,
			}];
			
			// すべてのサブテクスチャを走査して
			for (subTexture in subTextures) {
				// ぴったり当てはまる空き領域
				var fit:EmptyArea = null;
				
				// すべての空き領域について
				for (area in areas) {
					if (area.height >= subTexture.height && area.width >= subTexture.width) {
						if (fit == null || area.height <= fit.height) {
							fit = area;
						}
					}
				}
				
				// サブテクスチャを敷くことができる空き領域が存在しない
				if (fit == null) {
					break;
				}
				
				// ぴったり当てはまる空き領域を削除
				areas.remove(fit);
				
				// 配置したサブテクスチャの右にできる空き空間
				areas.push({
					x      : fit.x + subTexture.width,
					y      : fit.y,
					width  : fit.width - subTexture.width,
					height : subTexture.height
				});
				
				// 配置したサブテクスチャの下にできる空き空間
				areas.push({
					x      : fit.x,
					y      : fit.y + subTexture.height,
					width  : fit.width,
					height : fit.height - subTexture.height
				});
				
				var region:Region = {
					x      : fit.x,
					y      : fit.y,
					width  : subTexture.width,
					height : subTexture.height,
				};
				
				regions.set(subTexture, region);
				
			}
			
			// 敷き詰めたサブテクスチャが `numTextures` 個ならば充填完了
			if (Lambda.count(regions) == numTextures) {
				return { size: textureSize, regions: regions };
			}
		}
		
		// サブテクスチャを敷き詰めることができなかった
		return null;
	}
	
	
	
}
