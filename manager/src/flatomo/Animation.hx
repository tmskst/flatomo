package flatomo;
import flash.Vector;
import starling.animation.IAnimatable;
import starling.display.Image;
import starling.textures.Texture;

using flatomo.SectionTools;

/**
 * 連続したビットマップとセクションで構成されるアニメーション機能を提供する。
 * アニメーションは連続したビットマップに変換される。
 * この性質上、アニメーションは表示オブジェクトコンテナとしての役割を持たない。子へのアクセスもできない。
 * FPSの指定はできない。呼び出し元（Flatomo#juggler）の更新頻度に依存する。
 * アニメーションの再生ヘッドは、セクションによって制御される。
 */
class Animation extends Image implements IAnimatable implements IPlayhead {
	/*
	 * Animationクラスの責務は、セクション情報を元に再生ヘッドを制御することです。
	 * テクスチャの管理と描画は親の starling.display.MovieClipに任せます。
	 */
	
	/**
	 * アニメーションを生成する。
	 * 呼び出しは flatomo.AnimationCreator に制限される。
	 * @param	textures テクスチャ
	 * @param	sections　セクション
	 */
	@:allow(flatomo.FlatomoAssetManager)
	private function new(textures:Vector<Texture>, sections:Array<Section>) {
		if (textures.length == 0) {
			throw '少なくとも一つのテクスチャが必要です。';
		}
		
		super(textures[0]);
		this.textures = textures;
		this.playhead = new Playhead(update, sections);
	}
	
	/** テクスチャ */
	private var textures:Vector<Texture>;
	
	public var playhead(default, null):Playhead;
	
	public function advanceTime(time:Float):Void {
		playhead.advanceFrame(Std.int(time));
	}
	
	private function update():Void {
		texture = textures[playhead.currentFrame - 1];
	}
	
	
}
