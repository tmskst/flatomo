package flatomo;

class SectionTools {
	
	/**
	 * セクション情報を制御コードに変換する。
	 * @param	source 変換するセクション情報。
	 * @return 生成された制御コード。
	 */
	public static function toControlCodes(sections:Array<Section>):Map</*Frame*/Int, ControlCode> {
		var codes:Map<Int, ControlCode> = new Map<Int, ControlCode>();
		
		for (section in sections) {
			var code = toControlCode(section);
			if (code != null) {
				codes.set(code.frame, code.code);
			}
		}
		return codes;
	}
	
	// 制御コードなしをnullで表現するのはどうかと思う
	public static function toControlCode(section:Section): { frame:Int, code:ControlCode } {
		switch (section.kind) {
			case SectionKind.Loop : 
				return { frame: section.end, code: ControlCode.Goto(section.begin) };
			case SectionKind.Once : 
				return { frame: section.end, code: ControlCode.Stop };
			case SectionKind.Pass, SectionKind.Default : 
				// 追加するコードはない
				return null;
			case SectionKind.Standstill : 
				return { frame: section.begin, code: ControlCode.Stop };
			case SectionKind.Goto(goto) : 
				// TODO : SectionKind.Goto の仕様変更に追いついていません。
				/* codes.set(section.end, ControlCode.Goto(goto)); */
				return null;
		}
	}
	
}
