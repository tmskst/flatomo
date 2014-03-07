package flatomo.extension;

import flatomo.LibraryPath;
import haxe.Serializer;
import jsfl.Document;
import jsfl.EventType;
import jsfl.FLfile;
import jsfl.Instance;
import jsfl.Item;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.SymbolItem;

using jsfl.LibraryTools;
using jsfl.TimelineTools;
using flatomo.extension.ItemTools;
using flatomo.extension.DocumentTools;

class Publisher {
	
	private static var id:Int;
	
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (!document.isFlatomo()) { return; }
		writeLibrary();
		
		id = fl.addEventListener(EventType.POST_PUBLISH, postPublish);
		document.publish();
	}
	
	private static function writeLibrary():Void {
		var document:Document = fl.getDocumentDOM();
		var library = createLibrary(document.library);
		var swfPath:String = document.getSWFPathFromProfile();
		var fileUri = swfPath.substring(0, swfPath.lastIndexOf(".")) + "." + "flatomo";
		FLfile.write(fileUri, Serializer.run(library));
	}
	
	private static function postPublish():Void {
		clean(fl.getDocumentDOM().library);
		fl.removeEventListener(EventType.POST_PUBLISH, id);
	}
	
	// --------------------------------------------------------------------------------------------------
	
	/**
	 * マネージャーで使用するライブラリを生成する。
	 * @param	library 元となるライブラリ。
	 * @return 生成されたライブラリ。
	 */
	public static function createLibrary(library:Library):{ metadata:Map<LibraryPath, FlatomoItem>, libraryPaths:Map<String, LibraryPath> } {
		var metadata = new Map<LibraryPath, FlatomoItem>();
		var libraryPaths = new Map<String, LibraryPath>();
		
		library.scan_allSymbolItem(function (item:SymbolItem) {
			var libraryPath:String = getLibraryPath(item);
			var flatomoItem:FlatomoItem = item.getFlatomoItem();
			if (flatomoItem == null) {
				var sections = SectionCreator.fetchSections(item.timeline);
				flatomoItem = { sections: sections, animation: false };
			}
			metadata.set(libraryPath, flatomoItem);
			
			var id:Int = 0;
			item.timeline.scan_allInstance(function (instance:Instance) {
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
	
	private static function clean(library:Library):Void {
		library.scan_allSymbolItem(function (item:SymbolItem) {
			item.timeline.scan_allInstance(function (instance:Instance) {
				if (StringTools.startsWith(instance.name, "_FLATOMO_SYMBOL_INSTANCE_")) {
					instance.name = "";
				}
			});
		});
	}
	
	private static function getLibraryPath(item:Item):String {
		return if (item.linkageExportForAS) "F:" + item.linkageClassName else item.name;
	}
	
}
