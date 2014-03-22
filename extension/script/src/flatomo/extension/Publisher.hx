package flatomo.extension;

import flatomo.FlatomoLibrary;
import flatomo.LibraryPath;
import haxe.Serializer;
import jsfl.Document;
import jsfl.Element;
import jsfl.EventType;
import jsfl.FLfile;
import jsfl.Instance;
import jsfl.Item;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.Shape;
import jsfl.SymbolItem;
import jsfl.Text;

using jsfl.LibraryTools;
using jsfl.TimelineTools;
using flatomo.extension.ItemTools;
using flatomo.extension.DocumentTools;

class Publisher {
	
	private static var id:Int = 0;
	
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
		{
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf(".")) + "." + "flatomo";
			FLfile.write(fileUri, Serializer.run(library));
		}
		{
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf("/"));
			var files = Exporter.export(library);
			for (file in files) {
				FLfile.write(fileUri + "/" + file.name + ".hx", file.value);
			}
		}
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
	public static function createLibrary(library:Library):FlatomoLibrary {
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
			
			//var id:Int = 0;
			item.timeline.scan_allElement(function (element:Element) {
				setElement(libraryPaths, element, libraryPath);
			});
		});
		return { metadata : metadata, libraryPaths : libraryPaths };
	}
	
	private static function setElement(libraryPaths:Map<String, LibraryPath>, element:Element, libraryPath:LibraryPath):Void {
		if (Std.is(element, Shape)) {
			var shape:Shape = cast element;
			if (shape.isGroup) {
				for (member in shape.members) {
					setElement(libraryPaths, member, libraryPath);
				}
			}
		}
		if (Std.is(element, Instance)) {
			var instance:Instance = cast element;
			setLibraryPath(libraryPaths, libraryPath, instance, getLibraryPath(instance.libraryItem));
		}
		if (Std.is(element, Text)) {
			var text:Text = cast element;
			setLibraryPath(libraryPaths, libraryPath, text, "TextField");
		}
	}
	
	private static function setLibraryPath(libraryPaths:Map<String, LibraryPath>, libraryPath:String, element:Element, libPath:LibraryPath):Void {
		var elementName:String = libraryPath + "#";
		if (element.name == "") {
			element.name = '_FLATOMO_SYMBOL_INSTANCE_${id++}_';
		}
		elementName +=  element.name;
		libraryPaths.set(elementName, libPath);
	}
	
	private static function clean(library:Library):Void {
		library.scan_allSymbolItem(function (item:SymbolItem) {
			item.timeline.scan_allElement(function (element:Element) {
				removeElement(element);
			});
		});
	}
	
	private static function removeElement(element:Element):Void {
		var apply = function (instance:Element) {
			if (StringTools.startsWith(instance.name, "_FLATOMO_SYMBOL_INSTANCE_")) {
				instance.name = "";
			}
		};
		
		if (Std.is(element, Shape)) {
			var shape:Shape = cast element;
			if (shape.isGroup) {
				for (member in shape.members) {
					removeElement(member);
				}
			}
		}
		apply(element);
	}
	
	private static function getLibraryPath(item:Item):String {
		return if (item.linkageExportForAS) "F:" + item.linkageClassName else item.name;
	}
	
}
