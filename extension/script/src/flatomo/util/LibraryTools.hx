package flatomo.util;

import jsfl.Item;
import jsfl.Library;

class LibraryTools {
	
	public static function symbolItems(library:Library):Array<Item> {
		return library.items.filter(function (item) { return item.itemType.equals(GRAPHIC) || item.itemType.equals(MOVIE_CLIP); });
	}
	
	public static function getItem(library:Library, namePath:String):Item {
		 return library.items[library.findItemIndex(namePath)];
	}
	
}
