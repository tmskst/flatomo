package flatomo;

/**
 * Flatomoが拡張したItemオブジェクト（ライブラリ項目）。
 * このデータは、Item#addData()を用いて共有されない。"_EMBED_SWF_"を利用するために任意のElementのメタデータとして保存される。
 */
typedef FlatomoItem = {
	/** セクション情報 */
	var sections:Array<Section>;
	/** アニメーション属性 */
	var animation:Bool;
}
