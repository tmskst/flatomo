package flatomo;

/**
 * 表示オブジェクトを再構築するために必要なライブラリ。
 * ライブラリは、オーサリングツールから出力する際にスクリプト（JSFL）が生成する。
 */
typedef FlatomoLibrary = {
	/**
	 * ライブラリパスと拡張ライブラリ項目の組。
	 * 例えば、'500x500 => { animation : true, sections : [...] } ' など。
	 */
	var metadata:Map<ItemPath, FlatomoItem>;
	/**
	 * 任意のエレメント(Element)のパスと
	 * そのエレメントをインスタンス化するために使われたライブラリアイテムのパスの組。
	 * 例えば、'F:MyMovie#_FLATOMO_SYMBOL_INSTANCE_261_ => 500x500' など。
	 */
	var itemPaths:Map<ElementPath, ItemPath>;
}
