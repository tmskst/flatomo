package flatomo;

class SectionTools {
	
	public static function toControlCodes(source:Array<Section>):Map<Int, ControlCode> {
		var codes:Map<Int, ControlCode> = new Map<Int, ControlCode>();
		
		for (section in source) {
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
