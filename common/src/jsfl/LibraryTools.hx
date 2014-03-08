package jsfl;

class LibraryTools {

	/**
	 * @scan ライブラリに存在するすべてのSymbolItem
	 */
	public static function scan_allSymbolItem(library:Library, func:SymbolItem -> Void):Void {
		for (item in library.items) {
			if (Std.is(item, SymbolItem)) {
				func(cast(item, SymbolItem));
			}
		}
	}
	
}
