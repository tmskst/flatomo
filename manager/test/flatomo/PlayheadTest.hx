package flatomo;

import flatomo.display.Playhead;
import flatomo.SectionKind;
import massive.munit.Assert;

class PlayheadTest{

	public function new() { }
	
	@Test("生成直後のフレームは「1」")
	public function afterConstruct_currentFrame():Void {
		var sut = new Playhead(null, []); 
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("生成直後は再生中の状態にある")
	public function afterConstruct_isPlaying():Void {
		var sut = new Playhead(null, []); 
		Assert.areEqual(true, sut.isPlaying);
	}
	
	@Test("SectionKind.Loop: 再生ヘッドはセクション内でループする")
	public function currentFrame_Loop():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("SectionKind.Once: 再生ヘッドはセクションの最終フレームで停止する")
	public function currentFrame_Once():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 }
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("SectionKind.Pass: 再生ヘッドはセクションが終了しても進み続ける（次のセクションへと進む）")
	public function currentFrame_Pass():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Pass, begin: 4, end: 7 }
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("SectionKind.Pass: 最終フレームにはGoto(1)が挿入される")
	public function currentFrame_Pass2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 }
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
	}
	
	@Test("SectionKind.Standstill: 再生ヘッドはセクションの最初のフレームで停止する")
	public function currentFrame_Standstill():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Standstill, begin: 1, end: 3 }
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 再生ヘッドはセクションの最終フレームで指定したセクションへと移動する")
	public function currentFrame_Goto():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("c"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6},
			{ name: "c", kind: SectionKind.Goto("b"), begin: 7, end: 9}
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(7, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(8, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(9, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 遷移先セクションが自身の場合はLoopと同等")
	public function currentFrame_Goto2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("a"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6}
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
	}
	
	@Test("生成直後にplayを呼び出したときのフレームの遷移は呼び出さなかったときの遷移に等しい")
	public function afterConstruct_play():Void {
		var sut = new Playhead(function () {}, []);
		Assert.areEqual(1, sut.currentFrame);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
	}
	
	@Test("生成直後にstopを呼び出すと再生ヘッドは移動しない")
	public function afterConstruct_apply_stop():Void {
		var sut = new Playhead(function () {}, [{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }]);
		sut.stop();
		sut.advanceFrame(1);
		sut.advanceFrame(1);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("playを呼び出すと再生ヘッドは移動し始める")
	public function play_currentFrame():Void {
		var sut = new Playhead(function () {}, [{ name: "a", kind: SectionKind.Loop, begin: 1, end: 6 }]); 
		sut.advanceFrame(1); // 1
		sut.advanceFrame(1); // 2
		sut.advanceFrame(1); // 3
		Assert.areEqual(3, sut.currentFrame);
		
		sut.stop();
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(3, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("制御コードで停止した後にplayを呼び出すと再生ヘッドは移動し始める")
	public function play_currentFrame2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Playhead(function () {}, sections);
		sut.advanceFrame(1); // 1
		sut.advanceFrame(1); // 1
		sut.advanceFrame(1); // 2
		sut.advanceFrame(1); // 3
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		// 制御コード Stopにより再生ヘッドは停止した
		Assert.areEqual(3, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("生成直後にgotoGlobalAndPlayを呼び出して再生ヘッドを移動する")
	public function gotoGlobalAndPlay_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Playhead(function () {}, sections);
		// gotoAndPlayを呼び出すと同時にテクスチャが切り替わる（表示は変化しない）
		sut.gotoGlobalAndPlay(4);
		Assert.areEqual(4, sut.currentFrame);
		// gotoAndPlay呼び出し後、初めて描画されるテクスチャは「5」
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("生成直後にgotoAndPlayを呼び出して再生ヘッドを移動する")
	public function gotoAndPlay_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Playhead(function () {}, sections);
		// gotoAndPlayを呼び出すと同時にテクスチャが切り替わる（表示は変化しない）
		sut.gotoAndPlay("b");
		Assert.areEqual(4, sut.currentFrame);
		// gotoAndPlay呼び出し後、初めて描画されるテクスチャは「5」
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("生成直後にgotoGlobalAndStopを呼び出して再生ヘッドを移動する")
	public function gotoGlobalAndStop_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Playhead(function () {}, sections);
		// 生成直後のフレームは「1」
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoGlobalAndStop(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("生成直後にgotoAndStopを呼び出して再生ヘッドを移動する")
	public function gotoAndStop_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Playhead(function () {}, sections);
		// 生成直後のフレームは「1」
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoAndStop("b");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("gotoGlobalAndStop呼び出し後にplayを呼び出す")
	public function gotoGlobalAndStop_play_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 6 }
		];
		var sut = new Playhead(function () {}, sections);
		Assert.areEqual(1, sut.currentFrame);
		
		sut.gotoGlobalAndStop(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Ignore("あとでこの仕様を許容するかどうか判断する")
	@Test("生成直後に停止し、その後再生した場合はすぐに動き出す")
	public function afterConstruct_stop_play():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 6 }
		];
		var sut = new Playhead(function () {}, sections);
		sut.stop();
		sut.advanceFrame(1);
		sut.advanceFrame(1);
		sut.advanceFrame(1);
		Assert.areEqual(1, sut.currentFrame);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(2, sut.currentFrame);
	}
	
	@Ignore("StandstillのセクションへgotoAndPlayしたときの挙動")
	public function gotoAndPlay_Standstill():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(function () { }, sections);
		sut.gotoAndPlay("b");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame(1);
		Assert.areEqual(4, sut.currentFrame);
	}
	
}
