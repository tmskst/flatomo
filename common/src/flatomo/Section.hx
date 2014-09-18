package flatomo;

/** 再生ヘッドを制御するためのセクション */
typedef Section = {
	/** セクション名 */
	var name:String;
	/** セクションの種類 */
	var kind:SectionKind;
	/** 開始フレーム */
	var begin:Int;
	/** 終了フレーム */
	var end:Int;
}
