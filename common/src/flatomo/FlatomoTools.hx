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
	 * 対象（Element）のメタデータからFlatomoElementを取り出す
	 * @param	element 対象
	 * @return 対象から取り出したFlatomoElement
	 */
	public static function fetchElement(element:flash.display.DisplayObject):FlatomoElement {
		var metaData:Dynamic = untyped element.metaData;
		if (metaData == null) {
			throw '対象 ${element.name} にメタデータが存在しません。';
		}
		if (!Reflect.hasField(metaData, FIELD_NAME_ELEMENT)) {
			throw 'メタデータにフィールド ${FIELD_NAME_ELEMENT} が存在しません。';
		}
		
		var raw_data:String = Reflect.field(metaData, FIELD_NAME_ELEMENT);
		return Unserializer.run(raw_data);
	}
	
	/**
	 * 対象（Instance)をインスタンス化するために使用されたライブラリパスを取り出す
	 * @param	instance 対象
	 * @return 対象をインスタンス化するために使用されたライブラリパス
	 */
	public static function fetchLibraryPath(instance:flash.display.DisplayObject):LibraryPath {
		return fetchElement(instance).libraryPath;
	}
	
	/**
	 * 対象（Instance）をインスタンス化するために使用されたライブラリアイテムと関連付けられたFlatomoItemを取り出す。
	 * @param	source 対象
	 * @return 対象から取り出されたFlatomoItem
	 */
	public static function fetchItem(source:flash.display.DisplayObject):FlatomoItem {
		var libraryPath:LibraryPath;
		if (untyped source.metaData == null) {
			libraryPath = PREFIX_LINKAGED_ELEMENT + Type.getClassName(Type.getClass(source));
			trace('${source.name} にメタデータが見つかりません。パス ${libraryPath} でライブラリを探索します。');
		} else {
			libraryPath = fetchLibraryPath(source);
		}
		
		if (!Flatomo.library.exists(libraryPath)) {
			throw 'ライブラリにキー ${libraryPath} というオブジェクトは存在しません。';
		}
		
		return Flatomo.library.get(libraryPath);
	}
	
	/**
	 * FlatomoExtensionで生成された設定オブジェクトからライブラリを構築する。
	 * @param	source 設定オブジェクト
	 * @return 生成されたライブラリ
	 */
	@:allow(flatomo.Flatomo)
	private static function fetchLibrary(source:flash.display.DisplayObjectContainer):Map<LibraryPath, FlatomoItem> {
		var config:flash.display.DisplayObject = source.getChildByName(INSTANCE_NAME_CONFIG);
		if (config == null ) {
			throw '初期化に使用された設定オブジェクトは不適切な構造です。設定オブジェクトにインスタンス名 ${INSTANCE_NAME_CONFIG} が割り当てられた表示オブジェクトが存在しません。';
		}
		
		var metaData:Dynamic = untyped config.metaData;
		if (!Reflect.hasField(metaData, FIELD_NAME_LIBRARY)) {
			throw '初期化に使用された設定オブジェクトは不適切な構造です。設定オブジェクトのメタデータにフィールド ${FIELD_NAME_LIBRARY} が存在しません。';
		}
		
		return Unserializer.run(Reflect.field(metaData, FIELD_NAME_LIBRARY));
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
	 * 設定シンボルをライブラリに生成します。
	 */
	private static function createConfigSymbol():Void {
		if (!fl.getDocumentDOM().isFlatomo()) {
			Lib.throwError('不正な操作 : Flatomoが書き込みできないドキュメント ${fl.getDocumentDOM().name}で設定シンボル作成しようと試みました。');
		}
		
		var document:Document = fl.getDocumentDOM();
		var library:Library = document.library;
		
		// フォルダを作成
		if (library.itemExists(FLATOMO_SETTINGS_DIRECTORY_NAME)) {
			throw 'library.newFolder';
		}
		library.newFolder(FLATOMO_SETTINGS_DIRECTORY_NAME);
		
		// マネージャで読み込むシンボルを作成
		library.addNewItem("movie clip", '${FLATOMO_SETTINGS_DIRECTORY_NAME}/${FLATOMO_SETTINGS_CONFIG_OBJECT_NAME}');
		library.setItemProperty('linkageExportForAS', true);
		library.setItemProperty('linkageExportForRS', false);
		library.setItemProperty('linkageExportInFirstFrame', true);
		library.setItemProperty('linkageClassName', 'Config');
		
		// Elementを作成
		library.selectItem('flatomo/config');
		library.editItem();
		document.addNewText( { left: -1, top: -1, right: 30, bottom: 18 }, "CONFIG");
		document.selectAll();
		document.setElementProperty('textType', 'dynamic');
		document.setElementProperty('name', INSTANCE_NAME_CONFIG);
		
		document.exitEditMode();
	}
	
	/**
	 * ライブラリから設定シンボルを削除します。
	 */
	private static function deleteConfigSymbol():Void {
		if (!fl.getDocumentDOM().isFlatomo()) {
			Lib.throwError('不正な操作 : Flatomoが書き込みできないドキュメント ${fl.getDocumentDOM().name}で設定シンボルを削除しようと試みました。');
		}
		
		var library:Library = fl.getDocumentDOM().library;
		if (library.itemExists(FLATOMO_SETTINGS_DIRECTORY_NAME)) {
			library.deleteItem(FLATOMO_SETTINGS_DIRECTORY_NAME);
		}
	}
	
	/**
	 * ライブラリを設定オブジェクトに格納する。
	 * @param	data ライブラリ
	 */
	private static function setLibrary(data:Map<LibraryPath, FlatomoItem>):Void {
		if (!fl.getDocumentDOM().isFlatomo()) {
			Lib.throwError('不正な操作 : Flatomoが書き込みできないドキュメント ${fl.getDocumentDOM().name}で設定シンボルにライブラリを書き込もうと試みました。');
		}
		
		var flash:Flash = fl;
		var library:Library = flash.getDocumentDOM().library;
		flash.getDocumentDOM().setPublishDocumentData("_EMBED_SWF_", true);
		
		var config:Element = null;
		{
			var path:String = FLATOMO_SETTINGS_DIRECTORY_NAME + "/" + FLATOMO_SETTINGS_CONFIG_OBJECT_NAME;
			if (!library.itemExists(path)) {
				throw 'ライブラリにアイテム ${path} が見つかりません。';
			}
			var index:Int = library.findItemIndex(path);
			if (!Std.is(library.items[index], SymbolItem)) {
				throw '設定オブジェクト ${path} が不適切な形式です。';
			}
			
			var item:SymbolItem = cast(library.items[index], SymbolItem);
			if (item.timeline.frameCount != 1) {
				throw '設定オブジェクト ${path} のフレーム数は1でなければなりません。';
			}
			
			scan_allElement(item.timeline, function (element:Element) {
				if (element.name == INSTANCE_NAME_CONFIG) {
					config = element;
					return;
				}
			});
			if (config == null) {
				throw 'ライブラリアイテム ${path} に ${INSTANCE_NAME_CONFIG} というインスタンス名のインスタンスが見つかりません。';
			}
		}
		
		if (config.hasPersistentData(FIELD_NAME_LIBRARY)) {
			config.removePersistentData(FIELD_NAME_LIBRARY);
		}
		config.setPersistentData(FIELD_NAME_LIBRARY, PersistentDataType.STRING, Serializer.run(data));
		config.setPublishPersistentData(FIELD_NAME_LIBRARY, "_EMBED_SWF_", true);
	}
	
	/**
	 * マネージャーで使用するライブラリを生成する。
	 * @param	library 元となるライブラリ。
	 * @return 生成されたライブラリ。
	 */
	public static function createLibrary(library:Library):Map<LibraryPath, FlatomoItem> {
		var map = new Map<LibraryPath, FlatomoItem>();
		
		scan_allSymbolItem(library, function (item:SymbolItem) {
			var libraryPath:String = if (item.linkageExportForAS) PREFIX_LINKAGED_ELEMENT + item.linkageClassName else item.name;
			var flatomoItem:FlatomoItem = item.getFlatomoItem();
			if (flatomoItem == null) {
				var sections = SectionCreator.fetchSections(item.timeline);
				flatomoItem = { sections: sections, animation: false };
			}
			
			map.set(libraryPath, flatomoItem);
		});
		
		return map;
	}
	
	/**
	 * ライブラリ項目のすべてのElementについてメタデータを生成、格納します。
	 * @param	library ライブラリ
	 */
	private static function setAllElementPersistentData(library:Library):Void {
		if (!fl.getDocumentDOM().isFlatomo()) {
			Lib.throwError('不正な操作 : Flatomoが書き込みできないドキュメント ${fl.getDocumentDOM().name}でElementに対しメタデータを書き込もうと試みました。');
		}
		
		scan_allSymbolItem(library, function (item:SymbolItem) {
			scan_allInstance(item.timeline, function (instance:Instance) {
				var path:LibraryPath;
				if (instance.libraryItem.linkageExportForAS) {
					path = PREFIX_LINKAGED_ELEMENT + instance.libraryItem.linkageClassName;
				} else {
					path = instance.libraryItem.name;
				}
				
				var data:FlatomoElement = { libraryPath: path };
				instance.setPersistentData(FIELD_NAME_ELEMENT, PersistentDataType.STRING, Serializer.run(data));
				instance.setPublishPersistentData(FIELD_NAME_ELEMENT, "_EMBED_SWF_", true);
			});
		});
	}
	
	private static function deleteAllElementPersistentData():Void {
		if (!fl.getDocumentDOM().isFlatomo()) {
			Lib.throwError('不正な操作 : Flatomoが書き込みできないドキュメント ${fl.getDocumentDOM().name}でElementに対しメタデータを削除しようと試みました。');
		}
		
		scan_allSymbolItem(fl.getDocumentDOM().library, function (item:SymbolItem) {
			scan_allInstance(item.timeline, function (instance:Instance) {
				if (instance.hasPersistentData(FIELD_NAME_ELEMENT)) {
					instance.removePersistentData(FIELD_NAME_ELEMENT);
					instance.setPublishPersistentData(FIELD_NAME_ELEMENT, "_EMBED_SWF_", false);
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
			if (!StringTools.startsWith(item.name, FLATOMO_SETTINGS_DIRECTORY_NAME) && Std.is(item, SymbolItem)) {
				func(cast(item, SymbolItem));
			}
		}
	}
	
	
	#end
	
}
