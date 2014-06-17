package flatomo.display;

import flatomo.Section;

using flatomo.display.SectionTools;

/** セクション情報に対応した再生ヘッド */
class Playhead {

	/**
	 * 再生ヘッドを生成
	 * @param	sections セクション情報
	 */
	public function new(sections:Array<Section>) {
		this.sections = sections;
		this.codes = sections.toControlCodes();
		this.isPlaying = true;
		this.currentFrame = 1;
		this.nextFrame = 1;
	}
	
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
	
	/** 再生ヘッドを動作させる */
	public function play():Void {
		isPlaying = true;
	}
	
	/** 再生ヘッドを停止させる */
	public function stop():Void {
		isPlaying = false;
	}
	
	/**
	 * 指定したセクションで再生ヘッドを再生します。
	 * @param	sectionName 遷移先のセクション名
	 * @param	?increment 差分（frame）
	 */
	public function gotoAndPlay(sectionName:Dynamic, ?increment:Int = 0):Void {
		gotoGlobalAndPlay(findSection(sectionName) + increment);
	}
	
	/**
	 * 指定したセクションで再生ヘッドを停止します。
	 * @param	sectionName 遷移先のセクション名
	 * @param	?increment 差分（frame）
	 */
	public function gotoAndStop(sectionName:Dynamic, ?increment:Int = 0):Void {
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
	
	/**
	 * 指定したフレームで再生ヘッドを再生します。
	 * @param	frame 遷移先フレーム
	 */
	public function gotoGlobalAndPlay(frame:Int):Void {
		isPlaying = true;
		currentFrame = frame;
		nextFrame = frame + 1;
	}
	
	/**
	 * 指定したフレームで再生ヘッドを停止します。
	 * @param	frame 遷移先フレーム
	 */
	public function gotoGlobalAndStop(frame:Int):Void {
		isPlaying = false;
		currentFrame = frame;
		nextFrame = frame + 1;
	}
	
	/**
	 * アニメーションの再生ヘッドを1フレーム進める。
	 * 制御コードによって再生ヘッドが移動したり停止する可能性がある。
	 * @param	time 利用しない
	 */
	public function advanceFrame(frame:Int):Void {
		if (!isPlaying) { return; }
		
		currentFrame = nextFrame;
		
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
	
}
