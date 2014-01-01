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
			switch(section.kind) {
				case SectionKind.Loop : 
					codes.set(section.end, ControlCode.Goto(section.begin));
				case SectionKind.Once : 
					codes.set(section.end, ControlCode.Stop);
				case SectionKind.Pass : 
					// 追加するコードはない
				case SectionKind.Standstill : 
					codes.set(section.begin, ControlCode.Stop);
				case SectionKind.Goto(goto) : 
					codes.set(section.end, ControlCode.Goto(goto));
			}
		}
		
		return codes;
	}
	
}
