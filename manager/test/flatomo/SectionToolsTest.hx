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
	
	@Test("最終フレームに制御コードを挿入する処理がLoopを破壊しない")
	public function toControlCodes_Loop2():Void {
		var expected = ControlCode.Goto(11);
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Loop, begin: 1, end: 10 },
			{ name: "anonymous", kind: SectionKind.Loop, begin: 11, end: 20 }
		]);
		var actual = codes.get(20);
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
	public function toControlCodes_Standstill():Void {
		var expected = ControlCode.Stop;
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Standstill, begin: 1, end: 10 }
		]);
		var actual = codes.get(1);
		Assert.areEqual(expected, actual);
	}
	
	@Test("SectionKind.Pass: セクション内にオペコードは存在しない")
	public function toControlCodes_Pass():Void {
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Pass, begin: 1, end: 10 }
		]);
		Assert.isFalse(codes.exists(1));
		// 最終フレームには制御コードが挿入される
		Assert.areEqual(ControlCode.Goto(1), codes.get(10));
	}
	
	@Test("SectionKind.Default: SectionKind.Passと同等")
	public function toControlCodes_Default():Void {
		var codes = SectionTools.toControlCodes([
			{ name: "anonymous", kind: SectionKind.Default, begin: 1, end: 10 }
		]);
		Assert.isFalse(codes.exists(1));
		// 最終フレームには制御コードが挿入される
		Assert.areEqual(ControlCode.Goto(1), codes.get(10));
	}
	
	@Test("SectionKind.Goto: セクション内の最終フレームにGoto(next.begin)を追加する")
	public function toControlCodes_Goto():Void {
		var codes = SectionTools.toControlCodes([
			{ name: "a", kind: SectionKind.Goto("c"), begin: 1, end: 10 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 11, end: 20 },
			{ name: "c", kind: SectionKind.Goto("b"), begin: 21, end: 30 }
		]);
		Assert.areEqual(codes.get(10), ControlCode.Goto(21));
		Assert.areEqual(codes.get(30), ControlCode.Goto(11));
		Assert.areEqual(codes.get(20), ControlCode.Goto(1));
	}
	
	@Test("SectionKind.Goto: 遷移先の該当セクションが存在しないとき例外が送出される")
	public function toControlCodes_Goto_Error1():Void {
		var catched:Bool = false;
		try {
			var codes = SectionTools.toControlCodes([
				{ name: "a", kind: SectionKind.Goto("c"), begin: 1, end: 10 },
				{ name: "c", kind: SectionKind.Goto("a"), begin: 11, end: 20 },
				{ name: "c", kind: SectionKind.Goto("b"), begin: 21, end: 30 }
			]);
		} catch (error:Dynamic) {
			catched = true;
			Assert.isType(error, String);
		}
		Assert.isTrue(catched);
	}
	
	@Test("SectionKind.Goto: 遷移先の該当セクションが複数存在するとき例外が送出される")
	public function toControlCodes_Goto_Error2():Void {
		var catched:Bool = false;
		try {
			var codes = SectionTools.toControlCodes([
				{ name: "a", kind: SectionKind.Goto("z"), begin: 1, end: 10 },
				{ name: "b", kind: SectionKind.Goto("a"), begin: 11, end: 20 },
				{ name: "c", kind: SectionKind.Goto("b"), begin: 21, end: 30 }
			]);
		} catch (error:Dynamic) {
			catched = true;
			Assert.isType(error, String);
		}
		Assert.isTrue(catched);
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
