package flatomo;

import flatomo.display.Playhead;
import flatomo.SectionKind;
import massive.munit.Assert;

class PlayheadTest {

	public function new() { }
	
	/** 生成直後の状態に関するテスト */
	
	@Test("生成直後のフレームは「1」")
	public function afterConstruct_currentFrame():Void {
		var sut = new Playhead([]);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("生成直後は再生中の状態にある")
	public function afterConstruct_isPlaying():Void {
		var sut = new Playhead([]);
		Assert.areEqual(true, sut.isPlaying);
	}
	
	
	/** セクションの基本的動作テスト */
	
	@Test("SectionKind.Loop: 再生ヘッドはセクション内でループする")
	public function basic_section_loop():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 2 -> 3 -> 1 -> 2 -> 3 -> 1
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Once: 再生ヘッドはセクションの最終フレームで停止する")
	public function basic_section_once():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 2 -> 3 -> 3 -> 3
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("SectionKind.Pass: 再生ヘッドはセクションが終了しても進み続ける（次のセクションへと進む）")
	public function basic_section_pass():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Pass, begin: 4, end: 7 }
		];
		var sut = new Playhead(sections);
		// 次のセクションへと進むことだけを確認する
		// 1 -> 2 -> 3 -> 4 -> 5
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("SectionKind.Standstill: 再生ヘッドはセクションの最初のフレームで停止する")
	public function basic_section_standstill():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Standstill, begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 1 -> 1 
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 再生ヘッドはセクションの最終フレームで指定したセクションへと移動する")
	public function basic_section_goto():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("c"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6},
			{ name: "c", kind: SectionKind.Goto("b"), begin: 7, end: 9}
		];
		var sut = new Playhead(sections);
		// 1 -> 2 -> 3 -> 7 -> 8 -> 9 -> 4 -> 5 -> 6 -> 1
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame(); // Goto "c"
		Assert.areEqual(7, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(8, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(9, sut.currentFrame);
		sut.advanceFrame(); // Goto "b"
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame(); // Goto "a"
		Assert.areEqual(1, sut.currentFrame);
	}
	
	
	/** Passセクションの詳細テスト */

	@Test("SectionKind.Passのセクションしか存在しないときの動作はLoopセクションに等しい")
	public function section_pass_onlyPassSection():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 2 -> 3 -> 1 -> 2 -> 3 -> 1
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}

	
	@Test("SectionKind.Passのセクションが最終セクションのときは最初のセクションへと進む")
	public function section_pass_finalSection():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Pass, begin: 4, end: 7 }
		];
		var sut = new Playhead(sections);
		// 次のセクションへと進むことだけを確認する
		// 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 1
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(7, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}
	
	
	/** Gotoセクションの詳細テスト */
	
	@Test("遷移先セクションが自身の場合はLoopセクションに等しい")
	public function section_goto_gotoSelf():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("a"), begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 2 -> 3 -> 1 -> 2 -> 3 -> 1
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}
	
	
	/** playに関する基本的動作のテスト */
	
	@Test("生成直後にplayを呼び出したときのフレーム遷移は呼び出さなかったときのそれに等しい")
	public function basic_callPlayAfterConstruct():Void {
		var sut = new Playhead([]);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
	}
	
	@Test("再生中にplayを呼び出したときのフレーム遷移は呼び出さなかったときのそれに等しい")
	public function basic_callPlayRunning():Void {
		var sut = new Playhead([]);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.play();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	
	/** stopに関する基本的動作のテスト */
	
	@Test("生成直後にstopを呼び出すと再生ヘッドは停止する")
	public function basic_callStopAfterConstruct():Void {
		var sut = new Playhead([]);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}
	
	/** playとstopに関する基本的動作のテスト */
	
	@Test("停止中にplayを呼び出すと再生ヘッドは動き出す")
	public function basic_callPlayAfterStopping():Void {
		var sut = new Playhead([]);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
	}
	
	
	/** セクションとplayに関するテスト */
	
	@Test("Onceセクションで停止した後にplayを呼び出しても再生ヘッドは再生しない")
	public function callPlayAfterControlled_OnceSection():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 2 -> 3 -> 3 -> 3 play() -> 3 -> 3
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("Standstillセクションで停止した後にplayを呼び出しても再生ヘッドは再生しない")
	public function callPlayAfterControlled_StandstillSection():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Standstill, begin: 1, end: 3 }
		];
		var sut = new Playhead(sections);
		// 1 -> 1 -> 1 play -> 1 -> 1
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(1, sut.currentFrame);
	}
	
	
	/** gotoFrameに関する基本的動作のテスト */
	
	@Test("生成直後にgotoFrameを呼び出して再生ヘッドを移動させる")
	public function afterGotoFrame_currentFrame():Void {
		var sut = new Playhead([]);
		sut.gotoFrame(10);
		Assert.areEqual(10, sut.currentFrame);
	}
	
	
	/** gotoSectionに関する基本的動作のテスト */
	
	@Test("生成直後にgotoSectionを呼び出して再生ヘッドを移動させる")
	public function afterGotoSection_currentFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
	}
	
	
	/** 再生中に各セクションへgotoSectionで遷移する */
	
	@Test("再生中にLoopセクションへgotoSectionで遷移する")
	public function gotoSectionRunning_LoopSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にOnceセクションへgotoSectionで遷移する")
	public function gotoSectionRunning_OnceSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にPassセクションへgotoSectionで遷移する")
	public function gotoSectionRunning_PassSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にStandstillセクションへgotoSectionで遷移する")
	public function gotoSectionRunning_StandstillSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("再生中にGotoセクションへgotoSectionで遷移する")
	public function gotoSectionRunning_GotoSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	// TODO : インクリメントを含めた 各セクションへ遷移するgotoSectionのテスト
	
	/** 再生中に各セクションの先頭フレームへgotoFrameで遷移する */
	
	@Test("再生中にLoopセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameRunning_LoopSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にOnceセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameRunning_OnceSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にPassセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameRunning_PassSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にStandstillセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameRunning_StandstillSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("再生中にGotoセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameRunning_GotoSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	
	/** 再生中に各セクションの中央フレームへgotoFrameで遷移する */
	
	@Test("再生中にLoopセクションの中央へgotoFrameで遷移する")
	public function gotoFrameRunning_LoopSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("再生中にOnceセクションの中央へgotoFrameで遷移する")
	public function gotoFrameRunning_OnceSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("再生中にPassセクションの中央へgotoFrameで遷移する")
	public function gotoFrameRunning_PassSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("再生中にStandstillセクションの中央へgotoFrameで遷移する")
	public function gotoFrameRunning_StandstillSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("再生中にGotoセクションの中央へgotoFrameで遷移する")
	public function gotoFrameRunning_GotoSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	
	/** 再生中に各セクションの最終フレームへgotoFrameで遷移する */
	
	@Test("再生中にLoopセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameRunning_LoopSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("再生中にOnceセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameRunning_OnceSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("再生中にPassセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameRunning_PassSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(7, sut.currentFrame);
	}
	
	@Test("再生中にStandstillセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameRunning_StandstillSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("再生中にGotoセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameRunning_GotoSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	/* ************************************************************************************************ */
	
	/** 停止中に各セクションへgotoSectionで遷移する */
	
	@Test("停止中にLoopセクションへgotoSectionで遷移する")
	public function gotoSectionStopping_LoopSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にOnceセクションへgotoSectionで遷移する")
	public function gotoSectionStopping_OnceSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にPassセクションへgotoSectionで遷移する")
	public function gotoSectionStopping_PassSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にStandstillセクションへgotoSectionで遷移する")
	public function gotoSectionStopping_StandstillSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("停止中にGotoセクションへgotoSectionで遷移する")
	public function gotoSectionStopping_GotoSection():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoSection("a");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	/** 停止中に各セクションの先頭フレームへgotoFrameで遷移する */
	
	@Test("停止中にLoopセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameStopping_LoopSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にOnceセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameStopping_OnceSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にPassセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameStopping_PassSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にStandstillセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameStopping_StandstillSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("停止中にGotoセクションの先頭へgotoFrameで遷移する")
	public function gotoFrameStopping_GotoSectionStartFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	
	/** 停止中に各セクションの中央フレームへgotoFrameで遷移する */
	
	@Test("停止中にLoopセクションの中央へgotoFrameで遷移する")
	public function gotoFrameStopping_LoopSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("停止中にOnceセクションの中央へgotoFrameで遷移する")
	public function gotoFrameStopping_OnceSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("停止中にPassセクションの中央へgotoFrameで遷移する")
	public function gotoFrameStopping_PassSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("停止中にStandstillセクションの中央へgotoFrameで遷移する")
	public function gotoFrameStopping_StandstillSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("停止中にGotoセクションの中央へgotoFrameで遷移する")
	public function gotoFrameStopping_GotoSectionMiddleFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(5);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	
	/** 再生中に各セクションの最終フレームへgotoFrameで遷移する */
	
	@Test("停止中にLoopセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameStopping_LoopSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Loop, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("停止中にOnceセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameStopping_OnceSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Once, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("停止中にPassセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameStopping_PassSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Pass, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(7, sut.currentFrame);
	}
	
	@Test("停止中にStandstillセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameStopping_StandstillSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Standstill, begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Test("停止中にGotoセクションの最終フレームへgotoFrameで遷移する")
	public function gotoFrameStopping_GotoSectionFinalFrame():Void {
		var sections = [
			{ name: "-", kind: SectionKind.Loop, begin: 1, end: 3 },
			{ name: "a", kind: SectionKind.Goto("a"), begin: 4, end: 6 },
			{ name: "b", kind: SectionKind.Loop, begin: 7, end: 9 }
		];
		var sut = new Playhead(sections);
		sut.stop();
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoFrame(6);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceFrame();
		Assert.areEqual(4, sut.currentFrame);
	}
	
	
	// TODO : 例外に関するテストの追加
	
}
