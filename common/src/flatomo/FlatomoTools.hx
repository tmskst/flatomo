package flatomo;

#if js
import jsfl.Element;
import jsfl.Instance;
import jsfl.Item;
import jsfl.Library;
import jsfl.SymbolItem;
import jsfl.Timeline;
import flatomo.extension.SectionCreator;

using flatomo.extension.DocumentTools;
using flatomo.extension.ItemTools;
#end

class FlatomoTools {
	
	private static inline var PREFIX_LINKAGED_ELEMENT:String = "F:";
	
	#if flash
	
	/**
	 * 対象（Instance)をインスタンス化するために使用されたライブラリパスを取り出す
	 * @param	instance 対象
	 * @return 対象をインスタンス化するために使用されたライブラリパス
	 */
	public static function fetchLibraryPath(instance:flash.display.DisplayObject, parentLibraryPath:LibraryPath, library:Creator.Library):LibraryPath {
		return library.libraryPaths.get(parentLibraryPath + "#" +instance.name);
	}
	
	#end
	
	#if js
	
	/**
	 * マネージャーで使用するライブラリを生成する。
	 * @param	library 元となるライブラリ。
	 * @return 生成されたライブラリ。
	 */
	public static function createLibrary(library:Library):{ metadata:Map<LibraryPath, FlatomoItem>, libraryPaths:Map<String, LibraryPath> } {
		var metadata = new Map<LibraryPath, FlatomoItem>();
		var libraryPaths = new Map<String, LibraryPath>();
		
		scan_allSymbolItem(library, function (item:SymbolItem) {
			var libraryPath:String = getLibraryPath(item);
			var flatomoItem:FlatomoItem = item.getFlatomoItem();
			if (flatomoItem == null) {
				var sections = SectionCreator.fetchSections(item.timeline);
				flatomoItem = { sections: sections, animation: false };
			}
			metadata.set(libraryPath, flatomoItem);
			
			var id:Int = 0;
			scan_allInstance(item.timeline, function (instance:Instance) {
				var libPath:LibraryPath = getLibraryPath(instance.libraryItem);
				var instanceName:String = libraryPath + "#";
				if (instance.name == "") {
					instance.name = '_FLATOMO_SYMBOL_INSTANCE_${id++}_';
				}
				instanceName +=  instance.name;
				libraryPaths.set(instanceName, libPath);
			});
		});
		return { metadata : metadata, libraryPaths : libraryPaths };
	}
	
	private static function getLibraryPath(item:Item):String {
		return if (item.linkageExportForAS) PREFIX_LINKAGED_ELEMENT + item.linkageClassName else item.name;
	}
	
	private static function clean(library:Library):Void {
		scan_allSymbolItem(library, function (item:SymbolItem) {
			scan_allInstance(item.timeline, function (instance:Instance) {
				if (StringTools.startsWith(instance.name, "_FLATOMO_SYMBOL_INSTANCE_")) {
					instance.name = "";
				}
			});
		});
	}
	
	// --------------------------------------------------------------------------------------
	
	/**
	 * @scan Timelineに存在するすべてのElement
	 */
	public static function scan_allElement(timeline:Timeline, func:Element -> Void):Void {
		for (layer in timeline.layers) {
			for (frame in layer.frames) {
				for (element in frame.elements) {
					func(element);
				}
			}
		}
	}
	
	/**
	 * @scan Timelineに存在するすべてのInstance
	 */
	public static function scan_allInstance(timeline:Timeline, func:Instance -> Void):Void {
		scan_allElement(timeline, function (element:Element) {
			if (Std.is(element, Instance)) {
				func(cast(element, Instance));
			}
		});
	}
	
	/**
	 * @scan ライブラリに存在するすべてのSymbolItem
	 */
	public static function scan_allSymbolItem(library:Library, func:SymbolItem -> Void):Void {
		for (item in library.items) {
			func(cast(item, SymbolItem));
		}
	}
	
	
	#end
	
}
