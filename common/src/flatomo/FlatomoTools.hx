package flatomo;

import haxe.Serializer;
import haxe.Unserializer;
#if js
import jsfl.Lib;
import flatomo.extension.DocumentTools;
import flatomo.extension.SectionCreator;
import jsfl.PersistentDataType;
import jsfl.Document;
import jsfl.Text;
import jsfl.Element;
import jsfl.Flash;
import jsfl.Frame;
import jsfl.Instance;
import jsfl.Item;
import jsfl.Layer;
import jsfl.Library;
import jsfl.SymbolItem;
import jsfl.Timeline;
import jsfl.Lib.fl;

using flatomo.extension.DocumentTools;
using flatomo.extension.ItemTools;

#end

class FlatomoTools {
	
	private static inline var FIELD_NAME_ELEMENT:String = "f_element";
	private static inline var FIELD_NAME_LIBRARY:String = "f_library";
	private static inline var INSTANCE_NAME_CONFIG:String = "i_config";
	
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
	
	/*
	 * 設定シンボル Flatomo/Config はパブリッシュ直前に生成する。
	 * ドキュメントでFlatomoが有効かどうかは documentの永続データ領域に保存されている。
	 */
	
	/** Flatomoが使用する設定オブジェクトを格納するフォルダ名 */
	public static inline var FLATOMO_SETTINGS_DIRECTORY_NAME:String = "Flatomo";
	
	/** Flatomoが使用する設定オブジェクトの名前 */
	public static inline var FLATOMO_SETTINGS_CONFIG_OBJECT_NAME:String = "Config";
	
	
	/**
	 * マネージャーで使用するライブラリを生成する。
	 * @param	library 元となるライブラリ。
	 * @return 生成されたライブラリ。
	 */
	public static function createLibrary(library:Library):Map<LibraryPath, FlatomoItem> {
		var lib = new Map<LibraryPath, FlatomoItem>();
		scan_allSymbolItem(library, function (item:SymbolItem) {
			var libraryPath:String = getLibraryPath(item);
			var flatomoItem:FlatomoItem = item.getFlatomoItem();
			if (flatomoItem == null) {
				var sections = SectionCreator.fetchSections(item.timeline);
				flatomoItem = { sections: sections, animation: false };
			}
			lib.set(libraryPath, flatomoItem);
		});
		return lib;
	}
	
	private static function getLibraryPath(item:Item):String {
		return if (item.linkageExportForAS) PREFIX_LINKAGED_ELEMENT + item.linkageClassName else item.name;
	}
	
	private static function createHunk(library:Library):Map</*ElementPath*/String, LibraryPath> {
		var iss = new Map</*ElementPath*/String, LibraryPath>();
		scan_allSymbolItem(library, function (item:SymbolItem) {
			var libraryPath:String = getLibraryPath(item);
			var id:Int = 0;
			var data = new Map<String, LibraryPath>();
			scan_allInstance(item.timeline, function (instance:Instance) {
				var libPath:LibraryPath = getLibraryPath(instance.libraryItem);
				var instanceName:String = libraryPath + "#";
				if (instance.name == "") {
					instance.name = '_FLATOMO_SYMBOL_INSTANCE_${id++}_';
				}
				instanceName +=  instance.name;
				iss.set(instanceName, libPath);
			});
		});
		return iss;
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
			if (!StringTools.startsWith(item.name, FLATOMO_SETTINGS_DIRECTORY_NAME) && Std.is(item, SymbolItem)) {
				func(cast(item, SymbolItem));
			}
		}
	}
	
	
	#end
	
}
