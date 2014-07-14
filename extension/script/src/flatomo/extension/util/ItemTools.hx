package flatomo.extension.util;

import flatomo.FlatomoItem;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Item;
import jsfl.PersistentDataType;
import jsfl.SymbolItem;

class ItemTools {
	
	private static inline var DATA_NAME:String = "f_item";
	
	/**
	 * ItemからFlatomoItemを取り出す
	 * @param	item ライブラリ項目
	 * @return 取得したFlatomoItem
	 */
	public static function getFlatomoItem(symbolItem:SymbolItem):FlatomoItem {
		var latestSection:Array<Section> = SectionCreator.fetchSections(symbolItem.timeline);
		if (!symbolItem.hasData(DATA_NAME)) {
			return {
				sections			: latestSection,
				exportForFlatomo	: false,
				primitiveItem		: false,
				exportType			: ExportType.Dynamic,
				displayObjectType	: DisplayObjectType.Container,
			};
		}
		
		var flatomoItem:FlatomoItem = Unserializer.run(symbolItem.getData(DATA_NAME));
		// 最新のセクション情報と保存済みセクション情報を比較する。
		// 名前(name属性)が一致するものについては、保存済みセクションのkind属性を最新のセクションにコピーする。
		for (l in latestSection) {
			for (s in flatomoItem.sections) {
				if (l.name == s.name) { l.kind = s.kind; }
			}
		}
		flatomoItem.sections = latestSection;
		
		return flatomoItem;
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
