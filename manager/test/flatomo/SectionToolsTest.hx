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
	
	
}
