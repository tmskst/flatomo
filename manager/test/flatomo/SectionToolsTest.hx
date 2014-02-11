package flatomo;
import flatomo.ControlCode;
import flatomo.SectionKind;
import flatomo.SectionTools;
import haxe.Json;
import haxe.PosInfos;
import massive.munit.Assert;

private typedef Code = { frame:Int, code:ControlCode };

class SectionToolsTest {

	public function new() { }
	
	@Test("SectionKind.Loop: セクション内の最初のフレームにGoto(begin)を追加する")
	public function toControlCodeTest_Loop():Void {
		var expected = { frame: 10, code: ControlCode.Goto(1) };
		var actual = SectionTools.toControlCode({ name: "anonymous", kind: SectionKind.Loop, begin: 1, end: 10 });
		equals(expected, actual);
	}
	
	@Test("SectionKind.Once: セクション内の最終フレームにStopを追加する")
	public function toControlCodeTest_Once():Void {
		var expected = { frame: 10, code: ControlCode.Stop };
		var actual = SectionTools.toControlCode({ name: "anonymous", kind: SectionKind.Once, begin: 1, end: 10 });
		equals(expected, actual);
	}
	
	@Test("SectionKind.Standstill: セクション内の最初のフレームにStopを追加する")
	public function toControlCodeTest_Standstill():Void {
		var expected = { frame: 1, code: ControlCode.Stop };
		var actual = SectionTools.toControlCode({ name: "anonymous", kind: SectionKind.Standstill, begin: 1, end: 10 });
		equals(expected, actual);
	}
	
	@Test("SectionKind.Pass: セクション内にオペコードは存在しない")
	public function toControlCodeTest_Pass():Void {
		var actual = SectionTools.toControlCode({ name: "anonymous", kind: SectionKind.Pass, begin: 1, end: 10 });
		Assert.isNull(actual);
	}
	
	@Test("SectionKind.Default: SectionKind.Passと同等")
	public function toControlCodeTest_Default():Void {
		var expected = null;
		var actual = SectionTools.toControlCode({ name: "anonymous", kind: SectionKind.Default, begin: 1, end: 10 });
		Assert.areEqual(expected, actual);
	}
	
	@Ignore("未実装")
	@Test("SectionKind.Goto: ...")
	public function toControlCodeTest_Goto():Void {
		// ...
	}
	
	private static inline function equals(expected:Code, actual:Code):Void {
		Assert.areEqual(expected.frame, actual.frame);
		Assert.areEqual(expected.code, actual.code);
	}
	
	@Test("すべてのセクションが例外なく変換できる")
	public function toControlCodes1():Void {
		var sections = [
			{ name: "Loop", kind: SectionKind.Loop, begin: 1, end: 10 },
			{ name: "Once", kind: SectionKind.Once, begin: 11, end: 20 },
			{ name: "Pass", kind: SectionKind.Pass, begin: 21, end: 30 },
			{ name: "Default", kind: SectionKind.Default, begin: 31, end: 40 },
			{ name: "Standstill", kind: SectionKind.Standstill, begin: 41, end: 50 },
			{ name: "Goto", kind: SectionKind.Goto("Loop"), begin: 51, end: 60 }
		];
		SectionTools.toControlCodes(sections);
	}
	
	
}
