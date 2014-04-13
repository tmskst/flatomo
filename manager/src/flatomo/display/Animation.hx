package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
import haxe.ds.Vector;
import starling.animation.IAnimatable;
import starling.display.Image;
import starling.textures.Texture;

using flatomo.display.SectionTools;

/**
 * 連続したビットマップとセクションで構成されるアニメーション機能を提供する。
 * アニメーションは連続したビットマップに変換される。
 * この性質上、アニメーションは表示オブジェクトコンテナとしての役割を持たない。子へのアクセスもできない。
 * FPSの指定はできない。呼び出し元（Flatomo#juggler）の更新頻度に依存する。
 * アニメーションの再生ヘッドは、セクションによって制御される。
 */
class Animation extends Image implements ILayoutAdjusted implements IAnimatable implements IPlayhead {
	
	/**
	 * アニメーションを生成する。
	 * 呼び出しは flatomo.FlatomoAssetManager に制限される。
	 * @param	textures テクスチャ
	 * @param	sections　セクション情報
	 */
	@:allow(flatomo.FlatomoAssetManager)
	private function new(layouts:haxe.ds.Vector<Layout>, textures:flash.Vector<Texture>, sections:Array<Section>) {
		if (textures.length == 0) {
			throw '少なくとも一つのテクスチャが必要です。';
		}
		
		super(textures[0]);
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
		this.textures = textures;
		this.playhead = new Playhead(update, sections);
	}
	
	private var layouts:Vector<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
	/** テクスチャ */
	private var textures:flash.Vector<Texture>;
	
	/** 再生ヘッド */
	public var playhead(default, null):Playhead;
	
	/**
	 * 再生ヘッドを進める
	 * @param	time 今は使用しない
	 */
	public function advanceTime(time:Float):Void {
		playhead.advanceFrame(Std.int(time));
	}
	
	/** 描画処理 */
	private function update():Void {
		texture = textures[playhead.currentFrame - 1];
	}
	
}
