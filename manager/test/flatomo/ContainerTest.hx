package flatomo;
import flatomo.Container;
import flatomo.Layout;
import massive.munit.Assert;

@:access(flatomo.Container)
class ContainerTest {
	
	public function new() { }
	
	@Test("生成直後のフレームは「1」")
	public function currentFrame1():Void {
		var sut = new Container([], new Map <Int, Array<Layout>>(), []);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Loop: 再生ヘッドはセクション内でループする")
	public function currentFrame_Loop():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }
		];
		var sut = new Container([], new Map<Int, Array<Layout>>(), sections);
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
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("SectionKind.Standstill: 再生ヘッドはセクションの最初のフレームで停止する")
	public function currentFrame_Standstill():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Standstill, begin: 1, end: 10 }
		];
		var sut = new Container([], new Map<Int, Array<Layout>>(), sections);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Ignore("未実装")
	@Test("SectionKind.Goto: 再生ヘッドはセクションの最終フレームで指定したセクションへと移動する")
	public function currentFrame_Goto():Void {
		// ...
	}
	
}
