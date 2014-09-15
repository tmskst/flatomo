package flatomo.util;

import jsfl.Item;
import jsfl.Library;
import jsfl.SymbolItem;

class LibraryTools {
	
	/** ライブラリのうちシンボルアイテムのみの列挙 */
	public static function symbolItems(library:Library):Array<SymbolItem> {
		return untyped library.items.filter(function (item) { return item.itemType.equals(GRAPHIC) || item.itemType.equals(MOVIE_CLIP); });
	}
	
	/** ライブラリから指定したnamePathのアイテムを取得する */
	public static function getItem(library:Library, namePath:String):Item {
		return library.items[library.findItemIndex(namePath)];
	}
	
}
