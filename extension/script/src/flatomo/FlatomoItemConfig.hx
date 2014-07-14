package flatomo;

import flatomo.FlatomoItem;
import flatomo.FlatomoItem.DisplayObjectType;
import flatomo.FlatomoItem.ExportType;
import haxe.Resource;
import haxe.Template;
import jsfl.Document;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.Lib;
import jsfl.Lib.fl;
import jsfl.SymbolItem;

using Lambda;
using StringTools;
using flatomo.extension.util.ItemTools;
using flatomo.extension.util.DocumentTools;

class FlatomoItemConfig {
	
	private static function getName(resolve:EnumValue -> String -> Bool, enumValue:EnumValue, name:String):Bool {
		return enumValue.getName() == name;
	}
	
	private static function getGotoSectionName(resolve:SectionKind -> String -> Bool, kind:SectionKind, name:String):Bool {
		return switch (kind) {
			case SectionKind.Goto(sectionName) :
				sectionName == name;
			case _ :
				false;
		};
	}
	
	@:access(flatomo.extension.ItemTools)
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (document == null) {
			return Lib.alert("有効なドキュメントを開いてください");
		}
		if (!document.isFlatomo()) {
			return Lib.alert("Flatomoが有効でないドキュメントです");
		}
		
		/* スクリプトを実行するには、
		 * 1. ライブラリ項目を1つだけ選択している。
		 * 2. 選択されたライブラリ項目がシンボルアイテムであること。
		 */
		// 対象のシンボルアイテム
		var selectedSymbolItem:SymbolItem = null;
		{ // initialize selectedSymbolItem
			var selectedItems:Array<Item> = fl.getDocumentDOM().library.getSelectedItems();
			if (selectedItems.length != 1) {
				return Lib.alert("ライブラリ項目を1つだけ選択してください");
			}
			var selectedItem:Item = fl.getDocumentDOM().library.getSelectedItems()[0];
			if (!selectedItem.itemType.equals(ItemType.MOVIE_CLIP) && !selectedItem.itemType.equals(ItemType.GRAPHIC)) {
				return Lib.alert("シンボルアイテムを選択してください");
			}
			selectedSymbolItem = cast selectedItem;
		}
		
		// 対象のシンボルアイテムに保存された拡張情報
		var flatomoItem:FlatomoItem = selectedSymbolItem.getFlatomoItem();
		
		var symbolItemConfigTemplate = new Template(Resource.getString("FlatomoItemConfig"));
		var result:Dynamic = fl.xmlPanelFromString(symbolItemConfigTemplate.execute(
			{ // context
				linkage				: selectedSymbolItem.linkageClassName,
				exportForFlatomo	: flatomoItem.exportForFlatomo,
				primitiveItem		: flatomoItem.primitiveItem,
				exportType 			: flatomoItem.exportType,
				displayObjectType	: flatomoItem.displayObjectType,
				sectionList			: flatomoItem.sections.list(),
				sectionNameList		: flatomoItem.sections.list().map(function (section) { return section.name; } ),
			},
			{ // macros
				getName				: getName,
				getGotoSectionName	: getGotoSectionName
			}
		));
		
		// ダイアログがキャンセルされたら保存せずに終了
		if (result.dismiss == "cancel") { return; }
		
		// ダイアログを元に生成された拡張ライブラリ項目
		var latestFlatomoItem:FlatomoItem = {
			sections			: [],
			exportForFlatomo	: result.exportForFlatomo,
			primitiveItem		: result.primitiveItem,
			exportType			: ExportType.createByName(result.exportType),
			displayObjectType	: DisplayObjectType.createByName(result.displayObjectType),
		};
		
		// セクション情報を集計する
		for (field in Reflect.fields(result)) {
			if (field.startsWith("sectionKind")) {
				var sectionName:String = field.substring(field.lastIndexOf("_") + 1);
				var sectionKindName:String = Reflect.getProperty(result, field);
				var params = switch (sectionKindName) {
					case "Goto"	: [Reflect.getProperty(result, "sectionNameList_" + sectionName)];
					case _ 		: [];
				};
				latestFlatomoItem.sections.push({
					name: sectionName,
					kind: SectionKind.createByName(sectionKindName, params),
					begin: -1,
					end: -1,
				});
			}
		}
		
		selectedSymbolItem.setFlatomoItem(latestFlatomoItem);
		
		// Flatomo用に書き出し設定が有効ならシンボルをActionScript用に書き出しリンケージ設定を有効にする
		if (latestFlatomoItem.exportForFlatomo) {
			var linkage:String = Reflect.getProperty(result, "linkage");
			selectedSymbolItem.linkageExportForAS = true;
			selectedSymbolItem.linkageClassName = linkage;
		}
	}
}
