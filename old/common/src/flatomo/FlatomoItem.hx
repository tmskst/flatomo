package flatomo;

/**
 * Flatomoが拡張したItemオブジェクト（ライブラリ項目）。
 * ライブラリ項目1つに対してFlatomoItemが1つ対応する。
 */
typedef FlatomoItem = {
	/** セクション情報 */
	var sections:Array<Section>;
	var exportForFlatomo:Bool;
	var primitiveItem:Bool;
	var exportType:ExportType;
	var displayObjectType:DisplayObjectType;
}

enum ExportType {
	Dynamic;
	Static;
}

enum DisplayObjectType {
	Container;
	Animation;
}
