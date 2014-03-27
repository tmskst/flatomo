package jsfl;

class LibraryTools {

	/**
	 * @scan ライブラリに存在するすべてのSymbolItem
	 */
	public static function scan_allSymbolItem(library:Library, func:SymbolItem -> Void):Void {
		for (item in library.items) {
			switch (item.itemType) {
				case ItemType.GRAPHIC, ItemType.MOVIE_CLIP : func(cast item);
			}
		}
	}
	
}
