package flatomo;
import flash.geom.Rectangle;
import flash.Vector;
import starling.display.MovieClip;
import starling.textures.Texture;

class AnimationCreator {
	
	public static function isAlliedTo(target:flash.display.DisplayObject):Bool {
		var metaData:Dynamic = untyped target.metaData;
		return	(
				Std.is(target, flash.display.MovieClip) && 
				(metaData != null && Reflect.hasField(metaData, "anime")) &&
				(Reflect.getProperty(metaData, "anime") == "TRUE")
		);
	}
	
	// flash.display.MovieClip とセクション情報を元にアニメーションを作成します
	public static function create(source:flash.display.MovieClip, sections:Array<Section>):MovieClip {
		var textures:Vector<Texture> = new Vector<Texture>();
		var bounds:Rectangle = new Rectangle();
		
		// ソースの描画領域を計算
		for (frame in 1...(source.totalFrames + 1)) {
			source.gotoAndStop(frame);
			bounds = bounds.union(source.getBounds(source));
		}
		// テクスチャを生成
		for (frame in 1...(source.totalFrames + 1)) {
			source.gotoAndStop(frame);
			var bitmapData = Blitter.toBitmapData(source, bounds);
			textures.push(Texture.fromBitmapData(bitmapData));
		}
		
		var animation:Animation = new Animation(textures, sections);
		animation.transformationMatrix = source.transform.matrix;
		
		return animation;
	}
}