package flatomo.util;

import flatomo.ExtendedItem;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Item;
import jsfl.PersistentDataType;
import jsfl.SymbolItem;

class SymbolItemTools {
	
	private static inline var DATA_NAME:String = "f_item";
	
	/**
	 * SymbolItemからExtendedItemを取り出す
	 * @param	symbolItem ライブラリ項目
	 * @return 取得したExtendedItem
	 */
	public static function getExtendedItem(symbolItem:SymbolItem):ExtendedItem {
		var latestSection:Array<Section> = SectionCreator.fetchSections(symbolItem.timeline);
		if (!symbolItem.hasData(DATA_NAME)) {
			return {
				linkageExportForFlatomo : false,
				exportClassKind 		: ExportClassKind.Container,
				sections				: latestSection,
			};
		}
		
		var extendedItem:ExtendedItem = Unserializer.run(symbolItem.getData(DATA_NAME));
		// 最新のセクション情報と保存済みセクション情報を比較する。
		// 名前(name属性)が一致するものについては、保存済みセクションのkind属性を最新のセクションにコピーする。
		for (l in latestSection) {
			for (s in extendedItem.sections) {
				if (l.name == s.name) { l.kind = s.kind; }
			}
		}
		extendedItem.sections = latestSection;
		
		return extendedItem;
	}
	
	/**
	 * SymbolItemにExtendedItemを保存する
	 * @param	symbolItem 保存先
	 * @param	data 保存するデータ
	 */
	private static function setExtendedItem(symbolItem:SymbolItem, data:ExtendedItem):Void {
		removeExtendedItem(symbolItem);
		symbolItem.addData(DATA_NAME, PersistentDataType.STRING, Serializer.run(data));
	}
	
	/**
	 * SymbolItemからExtendedItemを削除する
	 * @param	symbolItem 対象のライブラリ項目
	 */
	private static function removeExtendedItem(symbolItem:SymbolItem):Void {
		if (symbolItem.hasData(DATA_NAME)) {
			symbolItem.removeData(DATA_NAME);
		}
	}
	
}
