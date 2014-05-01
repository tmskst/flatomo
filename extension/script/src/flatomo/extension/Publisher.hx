package flatomo.extension;

import flatomo.FlatomoItem;
import flatomo.FlatomoLibrary;
import flatomo.ItemPath;
import jsfl.Document;
import jsfl.Element;
import jsfl.ElementType;
import jsfl.EventType;
import jsfl.Instance;
import jsfl.Item;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.Shape;
import jsfl.SymbolItem;
import jsfl.Text;
import jsfl.Text.TextType;

using Lambda;
using StringTools;
using jsfl.LibraryTools;
using jsfl.TimelineTools;
using flatomo.extension.ItemTools;
using flatomo.extension.DocumentTools;
using flatomo.extension.FlatomoLibraryTools;

class Publisher {
	
	private static var listenerId:Int;
	
	@:access(FlatomoLibraryTools)
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (document == null || !document.isFlatomo()) { return; }
		
		var flatomoLibrary = FlatomoLibraryCreator.create(document.library);
		flatomoLibrary.publish(document);
		
		listenerId = fl.addEventListener(EventType.POST_PUBLISH, postPublish);
		document.publish();
	}
	
	private static function postPublish():Void {
		Cleaner.clean(fl.getDocumentDOM().library);
		fl.removeEventListener(EventType.POST_PUBLISH, listenerId);
	}
	
}

private class FlatomoLibraryCreator {
	
	/** マネージャで使用するライブラリを生成します */
	public static function create(library:Library):FlatomoLibrary {
		return new FlatomoLibraryCreator().createFlatomoLibrary(library);
	}
	
	/* ------------------------------------------------------------------------------------------------ */
	
	private function new() {
		this.id = 0;
		this.extendedItems = new Map<ItemPath, FlatomoItem>();
		this.itemPaths = new Map<String, ItemPath>();
	}
	
	private var id:Int;
	
	/** ライブラリパスとFlatomoItem（アニメーション指定とセクション情報）の対応関係 */
	private var extendedItems:Map<ItemPath, FlatomoItem>;
	
	private var itemPaths:Map<String, ItemPath>;
	
	private function createFlatomoLibrary(library:Library):FlatomoLibrary {
		// ライブラリ項目すべてについて走査
		library.scan_allSymbolItem(function (item:SymbolItem) {
			var itemPath:String = getItemPath(item);
			var flatomoItem:FlatomoItem = item.getFlatomoItem();
			// TODO : getFlatomoItem は NullObjectを返しても良いかも
			if (flatomoItem == null) {
				var sections = SectionCreator.fetchSections(item.timeline);
				flatomoItem = { sections: sections, animation: false };
			}
			extendedItems.set(itemPath, flatomoItem);
			
			// すべての Elementについて走査
			item.timeline.scan_allElement(function (element:Element) {
				analyzeElement(element, itemPath);
			});
		});
		return { extendedItems : extendedItems, itemPaths : itemPaths };
	}
	
	private function analyzeElement(element:Element, itemPath:ItemPath):Void {
		switch (element.elementType) {
			case ElementType.SHAPE : 
				var shape:Shape = cast element;
				if (shape.isGroup) {
					for (member in shape.members) {
						analyzeElement(member, itemPath);
					}
				}
			case ElementType.INSTANCE :
				var instance:Instance = cast element;
				setItemPath(itemPath, instance, getItemPath(instance.libraryItem));
			case ElementType.TEXT : 
				var text:Text = cast element;
				if (text.textType != TextType.STATIC) {
					setItemPath(itemPath, element, "TextField");
				}
		}
	}
	
	private function setItemPath(itemPath:String, element:Element, path:ItemPath):Void {
		if (element.name == "") {
			element.name = '_FLATOMO_SYMBOL_INSTANCE_${id++}_';
		}
		itemPaths.set(itemPath + "#" + element.name, path);
	}
	
	/**
	 * ライブラリ項目からライブラリパスを取り出す
	 * @param	item ライブラリ項目
	 * @return ライブラリ項目から取り出したライブラリパス。
	 * リンケージ設定が有効な場合は、'PREFIX + FQCN'。無効であれば、'Item.name'。
	 */
	private static function getItemPath(item:Item):String {
		return if (item.linkageExportForAS) "F:" + item.linkageClassName else item.name;
	}
	
}

/** ドキュメントを元に戻す責務 */
private class Cleaner {
	
	/** パブリッシュ時に変更したドキュメントを元に戻します */
	public static function clean(library:Library):Void {
		library.scan_allSymbolItem(function (item:SymbolItem) {
			item.timeline.scan_allElement(function (element:Element) {
				revertInstanceName(element);
			});
		});
	}
	
	/** パブリッシュ時に書き換えたインスタンス名を元に戻します */
	private static function revertInstanceName(element:Element):Void {
		if (element.elementType == ElementType.SHAPE) {
			var shape:Shape = cast element;
			if (shape.isGroup) {
				shape.members.iter(revertInstanceName);
			}
		}
		
		if (element.name.startsWith("_FLATOMO_SYMBOL_INSTANCE_")) {
			element.name = "";
		}
	}
	
}
