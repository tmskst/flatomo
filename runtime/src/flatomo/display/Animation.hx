package flatomo.display;

import flash.geom.Matrix;
import flatomo.display.ILayoutAdjusted;
import flatomo.Layout;
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
class Animation extends Image implements ILayoutAdjusted {
	
	/**
	 * アニメーションを生成する。
	 * 呼び出しは flatomo.GpuOperator に制限される。
	 * @param	textures テクスチャ
	 * @param	sections　セクション情報
	 */
	@:allow(flatomo.GpuOperator)
	private function new(layouts:Array<Layout>, textures:flash.Vector<Texture>) {
		if (textures.length == 0) {
			throw '少なくとも一つのテクスチャが必要です。';
		}
		
		super(textures[0]);
		this.matrix = new Matrix();
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
		this.textures = textures;
	}
	
	private var matrix:Matrix;
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
	/** テクスチャ */
	private var textures:flash.Vector<Texture>;
	
	/** 描画処理 */
	public function draw(frame:Int):Void {
		texture = textures[frame];
	}
	
}
