package flatomo;

/**
 * Element(JSFL)のメタデータプロパティに保存されるメタデータの形式。
 */
typedef FlatomoElement = {
	/** インスタンス化するために使用したライブラリアイテムへのパス。Instance#libraryItem#name(JSFL)に相当する。 */
	var libraryPath:LibraryPath;
}
