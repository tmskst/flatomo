package flatomo;

using flatomo.SectionTools;

class Playhead {

	public function new(update:Void -> Void, sections:Array<Section>) {
		this.update = update;
		this.sections = sections;
		this.codes = sections.toControlCodes();
		this.isPlaying = true;
		this.currentFrame = 1;
		this.nextFrame = 1;
	}
	
	private var update:Void -> Void;
	
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
		update();
	}
	
	public function gotoGlobalAndStop(frame:Int):Void {
		isPlaying = false;
		currentFrame = frame;
		nextFrame = frame + 1;
		update();
	}
	
	/**
	 * アニメーションの再生ヘッドを1フレーム進める。
	 * 制御コードによって再生ヘッドが移動したり停止する可能性がある。
	 * @param	time 利用しない
	 */
	public function advanceFrame(frame:Int):Void {
		if (!isPlaying) { return; }
		
		currentFrame = nextFrame;
		
		// 表示オブジェクトの更新
		update();
		
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
