package flatomo.extension;

import flatomo.FlatomoItem;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Item;
import jsfl.PersistentDataType;

class ItemTools {
	
	/**
	 * ItemからFlatomoItemを取り出す
	 * @param	item ライブラリ項目
	 * @return 取得したFlatomoItem
	 */
	public static function getFlatomoItem(item:Item):FlatomoItem {
		if (!item.hasData("f_item")) { return null; }
		return Unserializer.run(item.getData("f_item"));
	}
	
	/**
	 * ItemにFlatomoItemを保存する
	 * @param	item 保存先
	 * @param	data 保存するデータ
	 */
	private static function setFlatomoItem(item:Item, data:FlatomoItem):Void {
		if (item.hasData("f_item")) {
			item.removeData("f_item");
		}
		item.addData("f_item", PersistentDataType.STRING, Serializer.run(data));
	}
	
	/**
	 * ItemからFlatomoItemを削除する
	 * @param	item 対象のライブラリ項目
	 */
	private static function removeFlatomoItem(item:Item):Void {
		if (item.hasData("f_item")) {
			item.removeData("f_item");
		}
	}
	
}
