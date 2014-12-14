package flatomo;

/** 再生ヘッドを制御するためのセクション */
class Section {
	/** セクション名 */
	public var name(default, null):String;
	/** セクションの種類 */
	public var kind(default, null):SectionKind;
	/** 開始フレーム */
	public var begin(default, null):Int;
	/** 終了フレーム */
	public var end(default, null):Int;
	
	public function new(name:String, kind:SectionKind, begin:Int, end:Int) {
		this.name = name;
		this.kind = kind;
		this.begin = begin;
		this.end = end;
	}
	
}
