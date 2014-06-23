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
	}
	
	/**
	 * 再生ヘッドを制御するための制御コード
	 * @key　フレーム番号（再生ヘッドの位置）
	 * @value　フレームに対応する制御コード
	 */
	private var codes:Map<Int, ControlCode>;
	
	/** 現在の再生ヘッドの位置 */
	public var currentFrame(default, null):Int;
	
	/** タイムラインのセクション情報 */
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
	 * 指定したセクションに遷移します。
	 * @param	sectionName 遷移先セクション名
	 */
	public function gotoSection(sectionName:String, increment:Int = 0):Void {
		gotoFrame(fetchSectionStartFrame(sectionName) + increment);
	}	
	
	/**
	 * 指定したフレームに遷移します。
	 * @param	frame 遷移先フレーム（FrameIndex）
	 */
	public function gotoFrame(frame:Int):Void {
		currentFrame = frame;
	}
	
	/**
	 * 指定したセクションの開始フレームを取り出す
	 * @param	sectionName 対象のセクション名
	 * @return 対象のセクションの開始フレーム
	 */
	private function fetchSectionStartFrame(sectionName:String):Int {
		for (section in sections) {
			if (section.name == sectionName) {
				return section.begin;
			}
		}
		throw 'セクション ${sectionName} が見つかりません。';
	}
	
	/**
	 * アニメーションの再生ヘッドを1フレーム進める。
	 * 制御コードによって再生ヘッドが移動したり停止する可能性がある。
	 */
	public function advanceFrame():Void {
		if (!isPlaying) {
			return;
		}
		
		if (codes.exists(currentFrame)) {
			switch (codes.get(currentFrame)) {
				case ControlCode.Goto(frame) :
					this.currentFrame = frame;
				case ControlCode.Stop :
					isPlaying = false;
			}
		} else {
			this.currentFrame = currentFrame + 1;
		}
	}
	
}
