package flatomo.display;

class SectionTools {
	
	/**
	 * セクション情報を制御コードに変換する。
	 * @param	source 変換するセクション情報。
	 * @return 生成された制御コード。
	 */
	public static function toControlCodes(sections:Array<Section>):Map</*Frame*/Int, ControlCode> {
		var codes:Map<Int, ControlCode> = new Map<Int, ControlCode>();
		var totalFrames:Int = 0;
		
		for (section in sections) {
			totalFrames = Std.int(Math.max(totalFrames, section.end));
			
			switch (section.kind) {
			case SectionKind.Loop : 
				codes.set(section.end, ControlCode.Goto(section.begin));
			case SectionKind.Once : 
				codes.set(section.end, ControlCode.Stop);
			case SectionKind.Pass : 
				// 追加するコードはない
			case SectionKind.Stop : 
				for (index in section.begin...(section.end + 1)) {
					codes.set(index, ControlCode.Stop);
				}
			case SectionKind.Goto(destinationSectionName) : 
				var destination = Lambda.filter(sections, function(s:Section):Bool {
					return s.name == destinationSectionName;
				});
				if (destination.length != 1) {
					throw if (destination.isEmpty()) {
						'遷移先のセクション ${destinationSectionName} が見つかりません。';
					} else {
						'遷移先のセクション ${destinationSectionName} が複数見つかりました。';
					}
				}
				
				codes.set(section.end, ControlCode.Goto(destination.first().begin));
			}
		}
		
		// 最終セクションの最終フレームに制御コードを挿入する
		if (!codes.exists(totalFrames)) {
			codes.set(totalFrames, ControlCode.Goto(1));
		}
		
		return codes;
	}
	
}
