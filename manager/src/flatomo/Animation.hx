package flatomo;
import flash.Vector;
import starling.animation.IAnimatable;
import starling.display.Image;
import starling.textures.Texture;

using flatomo.SectionTools;

/**
 * 連続したビットマップとセクションで構成されるアニメーション機能を提供する。
 * アニメーションは連続したビットマップに変換される。この性質上、アニメーションは表示オブジェクトコンテナとしての役割を持たない。子へのアクセスもできない。
 * FPSの指定はできない。呼び出し元（Flatomo#juggler）の更新頻度に依存する。
 * アニメーションの再生ヘッドは、セクションによって制御される。
 */
class Animation extends Image implements IAnimatable {
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
	@:allow(flatomo.AssetFactory)
	private function new(textures:Vector<Texture>, sections:Array<Section>) {
		if (textures.length == 0) {
			throw '少なくとも一つのテクスチャが必要です。';
		}
		
		super(textures[0]);
		this.textures = textures;
		this.sections = sections;
		this.codes = sections.toControlCodes();
		this.isPlaying = true;
		this.currentFrame = 1;
		this.nextFrame = 1;
	}
	
	/** テクスチャ */
	private var textures:Vector<Texture>;
	
	/**
	 * 再生ヘッドを制御するための制御コード
	 * @key　フレーム番号（再生ヘッドの位置）
	 * @value　フレームに対応する制御コード
	 */
	private var codes:Map<Int, ControlCode>;
	
	/** 現在の再生ヘッドの位置 */
	public var currentFrame(default, null):Int;
	
	private var nextFrame:Int;
	
	private var sections:Array<Section>;
	
	/** 再生中かどうか */
	public var isPlaying(default, null):Bool;
	
	/**
	 * アニメーションの再生ヘッドを1フレーム進める。
	 * 制御コードによって再生ヘッドが移動したり停止する可能性がある。
	 * @param	time 利用しない
	 */
	public function advanceTime(time:Float):Void {
		if (!isPlaying) { return; }
		
		currentFrame = nextFrame;
		
		// テクスチャの更新
		texture = textures[currentFrame - 1];
		
		// 制御コード処理
		nextFrame = currentFrame + 1;
		if (codes.exists(currentFrame)) {
			switch (codes.get(currentFrame)) {
				case ControlCode.Goto(frame) :
					nextFrame = frame;
				case ControlCode.Stop : 
					this.isPlaying = false;
			}
		}
		
	}
	
	public function play():Void {
		isPlaying = true;
	}
	
	public function stop():Void {
		isPlaying = false;
	}
	
	public function gotoAndPlay(sectionName:String, ?increment:Int = 0):Void {
		gotoGlobalAndPlay(findSection(sectionName) + increment);
	}
	
	public function gotoAndStop(sectionName:String, ?increment:Int = 0):Void {
		gotoGlobalAndStop(findSection(sectionName) + increment);
	}
	
	private function findSection(sectionName:String):Int {
		for (section in sections) {
			if (section.name == sectionName) {
				return section.begin;
			}
		}
		throw 'セクション ${sectionName} が見つかりません。';
	}
	
	public function gotoGlobalAndPlay(frame:Int):Void {
		isPlaying = true;
		currentFrame = frame;
		nextFrame = frame + 1;
		texture = textures[currentFrame - 1];
	}
	
	public function gotoGlobalAndStop(frame:Int):Void {
		isPlaying = false;
		currentFrame = frame;
		nextFrame = frame + 1;
		texture = textures[currentFrame - 1];
	}
	
}
