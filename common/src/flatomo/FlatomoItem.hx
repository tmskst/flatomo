package flatomo;

/**
 * Flatomoが拡張したItemオブジェクト（ライブラリ項目）。
 * ライブラリ項目1つに対してFlatomoItemが1つ対応する。
 */
typedef FlatomoItem = {
	/** セクション情報 */
	var sections:Array<Section>;
	/** アニメーション属性 */
	var animation:Bool;
}
