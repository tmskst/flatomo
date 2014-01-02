package flatomo;
import flash.Vector;
import starling.display.MovieClip;
import starling.textures.Texture;

using flatomo.SectionTools;

/**
 * 連続したビットマップとセクションで構成されるアニメーション機能を提供する。
 * アニメーションは連続したビットマップに変換される。この性質上、アニメーションは表示オブジェクトコンテナとしての役割を持たない。子へのアクセスもできない。
 * FPSの指定はできない。呼び出し元（Flatomo#juggler）の更新頻度に依存する。
 * アニメーションの再生ヘッドは、セクションによって制御される。
 */
class Animation extends MovieClip {
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
	@:allow(flatomo.AnimationCreator)
	private function new(textures:Vector<Texture>, sections:Array<Section>) {
		// 更新頻度は呼び出し元(Flatomo#juggler)に依存する。
		super(textures, 1.00);
		this.codes = sections.toControlCodes();
	}
	
	/**
	 * 再生ヘッドを制御するための制御コード
	 * @key　フレーム番号（再生ヘッドの位置）
	 * @value　フレームに対応する制御コード
	 */
	private var codes:Map<Int, ControlCode>;
	
	/**
	 * アニメーションの再生ヘッドを1フレーム進める。
	 * 制御コードによって再生ヘッドが移動したり停止する可能性がある。
	 * @param	time 利用しない
	 */
	public override function advanceTime(time:Float):Void {
		if (codes.exists(currentFrame)) {
			switch (codes.get(currentFrame)) {
				case ControlCode.Stop : 
					this.pause();
					return;
				case ControlCode.Goto(frame) :
					this.currentFrame = frame;
			}
		}
		super.advanceTime(time);
	}
	
}
