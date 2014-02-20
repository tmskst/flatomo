package flatomo;
import flash.geom.Rectangle;
import flash.Vector;
import starling.display.MovieClip;
import starling.textures.Texture;

/**
 * アニメーションの生成手段を提供する。
 */
@:allow(flatomo.Creator)
class AnimationCreator {
	
	/**
	 * 対象がアニメーションかどうかを判定する。
	 * @param	target 判定の対象。
	 * @return 対象がアニメーションなら真。
	 */
	private static function isAlliedTo(target:flash.display.DisplayObject):Bool {
		/*
		 * アニメーションである条件は、
		 * 1. 対象がflash.display.MovieClipであること。
		 * 2. 対象のアニメーション属性が有効（真）であること。
		 */
		// TODO : 式をひとつまとめないでください。
		if (!Std.is(target, flash.display.MovieClip)) { return false; }
		
		var item:FlatomoItem = FlatomoTools.fetchItem(target);
		return item != null && item.animation;
	}
	
	/**
	 * flash.display.MovieClip とセクション情報を元にアニメーションを作成する。
	 * @param	source アニメーションの元となるムービークリップ。
	 * @param	sections アニメーションの再生ヘッドを制御するセクション情報。
	 * @return 生成されたアニメーション。
	 */
	private static function create(source:flash.display.MovieClip, sections:Array<Section>):Void {
		if (Flatomo.exists(FlatomoTools.fetchLibraryPath(source))) { return; }
		
		var textures:Vector<Texture> = new Vector<Texture>();
		var bounds:Rectangle = new Rectangle();
		
		// ソースの描画領域を計算
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			bounds = bounds.union(source.getBounds(source));
		}
		// テクスチャを生成
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			var bitmapData = Blitter.toBitmapData(source, bounds);
			textures.push(Texture.fromBitmapData(bitmapData));
		}
		
		// アニメーションを生成
		Flatomo.addSource(FlatomoTools.fetchLibraryPath(source), Source.Animation(source.name, textures, sections));
	}
}
