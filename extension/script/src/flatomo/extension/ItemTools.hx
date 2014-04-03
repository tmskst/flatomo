package flatomo.extension;

import flatomo.FlatomoItem;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Item;
import jsfl.PersistentDataType;

class ItemTools {
	
	private static inline var DATA_NAME:String = "f_item";
	
	/**
	 * ItemからFlatomoItemを取り出す
	 * @param	item ライブラリ項目
	 * @return 取得したFlatomoItem
	 */
	public static function getFlatomoItem(item:Item):FlatomoItem {
		if (!item.hasData(DATA_NAME)) { return null; }
		return Unserializer.run(item.getData(DATA_NAME));
	}
	
	/**
	 * ItemにFlatomoItemを保存する
	 * @param	item 保存先
	 * @param	data 保存するデータ
	 */
	private static function setFlatomoItem(item:Item, data:FlatomoItem):Void {
		removeFlatomoItem(item);
		item.addData(DATA_NAME, PersistentDataType.STRING, Serializer.run(data));
	}
	
	/**
	 * ItemからFlatomoItemを削除する
	 * @param	item 対象のライブラリ項目
	 */
	private static function removeFlatomoItem(item:Item):Void {
		if (item.hasData(DATA_NAME)) {
			item.removeData(DATA_NAME);
		}
	}
	
}
