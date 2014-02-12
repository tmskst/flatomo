package flatomo;
import flatomo.ControlCode;
import flatomo.SectionKind;
import flatomo.SectionTools;
import haxe.Json;
import haxe.PosInfos;
import massive.munit.Assert;

class SectionToolsTest {

	public function new() { }
	
	@Test("SectionKind.Loop: セクション内の最終フレームにGoto(begin)を追加する")
	public function toControlCodes_Loop():Void {
		var expected = ControlCode.Goto(1);
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Loop, begin: 1, end: 10 }
		]);
		var actual = codes.get(10);
		Assert.areEqual(expected, actual);
	}
	
	@Test("SectionKind.Once: セクション内の最終フレームにStopを追加する")
	public function toControlCodes_Once():Void {
		var expected = ControlCode.Stop;
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Once, begin: 1, end: 10 }
		]);
		var actual = codes.get(10);
		Assert.areEqual(expected, actual);
	}
	
	@Test("SectionKind.Standstill: セクション内の最初のフレームにStopを追加する")
	public function toControlCodeTest_Standstill():Void {
		var expected = ControlCode.Stop;
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Standstill, begin: 1, end: 10 }
		]);
		var actual = codes.get(1);
		Assert.areEqual(expected, actual);
	}
	
	@Test("SectionKind.Pass: セクション内にオペコードは存在しない")
	public function toControlCodeTest_Pass():Void {
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Pass, begin: 1, end: 10 }
		]);
		Assert.isFalse(codes.exists(1));
		Assert.isFalse(codes.exists(10));
	}
	
	@Test("SectionKind.Default: SectionKind.Passと同等")
	public function toControlCodeTest_Default():Void {
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Default, begin: 1, end: 10 }
		]);
		Assert.isFalse(codes.exists(1));
		Assert.isFalse(codes.exists(10));
	}
	
	@Ignore("未実装")
	@Test("SectionKind.Goto: ...")
	public function toControlCodeTest_Goto():Void {
		// ...
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
