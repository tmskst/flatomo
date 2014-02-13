package flatomo;
import flatomo.Container;
import flatomo.Layout;
import massive.munit.Assert;

@:access(flatomo.Container)
class ContainerTest {
	
	public function new() { }
	
	@Test("生成直後のフレームは「1」")
	public function afterConstruct_currentFrame():Void {
		var sut = new Container([], new Map <Int, Array<Layout>>(), []);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("生成直後は可視状態にある")
	public function afterConstruct_visible():Void {
		var sut = new Container([], new Map <Int, Array<Layout>>(), []);
		Assert.areEqual(true, sut.visible);
	}
	
	@Test("生成直後は再生中の状態にある")
	public function afterConstruct_isPlaying():Void {
		var sut = new Container([], new Map <Int, Array<Layout>>(), []);
		Assert.areEqual(true, sut.isPlaying);
	}
	
	@Test("SectionKind.Loop: 再生ヘッドはセクション内でループする")
	public function currentFrame_Loop():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }
		];
		var sut = new Container([], new Map<Int, Array<Layout>>(), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Once: 再生ヘッドはセクションの最終フレームで停止する")
	public function currentFrame_Once():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 }
		];
		var sut = new Container([], new Map<Int, Array<Layout>>(), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("SectionKind.Pass: 再生ヘッドはセクションが終了しても進み続ける（次のセクションへと進む）")
	public function currentFrame_Pass():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Pass, begin: 4, end: 7 }
		];
		var sut = new Container([], new Map<Int, Array<Layout>>(), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("SectionKind.Pass: 最終フレームにはGoto(1)が挿入される")
	public function currentFrame_Pass2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 }
		];
		var sut = new Container([], new Map < Int, Array<Layout> > (), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
	}
	
	@Test("SectionKind.Standstill: 再生ヘッドはセクションの最初のフレームで停止する")
	public function currentFrame_Standstill():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Standstill, begin: 1, end: 10 }
		];
		var sut = new Container([], new Map<Int, Array<Layout>>(), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 再生ヘッドはセクションの最終フレームで指定したセクションへと移動する")
	public function currentFrame_Goto():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("c"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6},
			{ name: "c", kind: SectionKind.Goto("b"), begin: 7, end: 9}
		];
		var sut = new Container([], new Map <Int, Array<Layout>>(), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(7, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(8, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(9, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 遷移先セクションが自身の場合はLoopと同等")
	public function currentFrame_Goto2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("a"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6}
		];
		var sut = new Container([], new Map < Int, Array<Layout> > (), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
	}
}
