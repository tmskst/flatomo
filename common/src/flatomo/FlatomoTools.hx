package flatomo;

import haxe.Serializer;
import haxe.Unserializer;

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
	
	/** Flatomoが使用する設定オブジェクトを格納するフォルダ名 */
	public static inline var FLATOMO_SETTINGS_DIRECTORY_NAME:String = "Flatomo";
	
	/** Flatomoが使用する設定オブジェクトの名前 */
	public static inline var FLATOMO_SETTINGS_CONFIG_OBJECT_NAME:String = "Config";
	
	/** 制御レイヤー名 */
	public static inline var CONTROL_LAYER_NAME:String = "FlatomoControlLayer";
	
	/**
	 * ライブラリを設定オブジェクトに格納する。
	 * @param	data ライブラリ
	 */
	public static function setLibrary(data:Map<LibraryPath, FlatomoItem>):Void {
		var flash:Flash = untyped fl;
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
			
			loop_allElement(item.timeline, function (element:Element) {
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
		config.setPersistentData(FIELD_NAME_LIBRARY, "string", Serializer.run(data));
		config.setPublishPersistentData(FIELD_NAME_LIBRARY, "_EMBED_SWF_", true);
	}
	
	/**
	 * マネージャーで使用するライブラリを生成する。
	 * @param	library 元となるライブラリ。
	 * @return 生成されたライブラリ。
	 */
	public static function createLibrary(library:Library):Map<LibraryPath, FlatomoItem> {
		var map = new Map<LibraryPath, FlatomoItem>();
		
		loop_allSymbolItem(library, function (item:SymbolItem) {
			var libraryPath:String = if (item.linkageExportForAS) PREFIX_LINKAGED_ELEMENT + item.linkageClassName else item.name;
			var sections:Array<Section> = fetchSections(item.timeline);
			
			map.set(libraryPath, { sections: sections, animation: false } );
		});
		
		return map;
	}
	
	/**
	 * ライムラインを元にセクション情報を抽出します。
	 * @param	timeline 元となるタイムライン
	 * @return 生成されたセクション情報
	 */
	public static function fetchSections(timeline:Timeline):Array<Section> {
		// タイムライン中から制御レイヤーを抽出
		var layers:Array<Layer> = timeline.layers.filter(
			function(layer:Layer):Bool { return layer.name == CONTROL_LAYER_NAME; }
		);
		
		// 制御レイヤーが存在しない場合は自動的にセクションが生成される。
		if (layers.length == 0) {
			untyped fl.trace('タイムライン ${timeline.name} に制御レイヤーが存在しません。セクションを自動的に生成します。');
			return [{ name: "anonymous", kind: SectionKind.Once, begin: 1, end: timeline.frameCount }];
		}
		
		// 制御レイヤーが複数存在する場合はエラーを送出する。
		if (layers.length != 1) {
			throw '複数のコントロールレイヤーが見つかりました。';
		}
		
		var keyFrames:Array<Int> = new Array<Int>();
		
		// 制御レイヤーのキーフレームを探索
		var controlLayer:Layer = layers.shift();
		var frames:Array<Frame> = controlLayer.frames;
		for (i in 0...frames.length) {
			if (i == frames[i].startFrame) { keyFrames.push(i); }
		}
		keyFrames.push(controlLayer.frameCount);
		
		// セクションの生成
		var sections:Array<Section> = new Array<Section>();
		for (i in 0...keyFrames.length - 1) {
			var frame:Frame = frames[keyFrames[i]];
			sections.push({ name: frame.name, kind: SectionKind.Once, begin: keyFrames[i] + 1, end: keyFrames[i + 1] });
		}
		
		return sections;
	}
	
	/**
	 * ライブラリ項目のすべてのElementについてメタデータを生成、格納します。
	 * @param	library ライブラリ
	 */
	public static function setAllElementPersistentData(library:Library):Void {
		loop_allSymbolItem(library, function (item:SymbolItem) {
			loop_allInstance(item.timeline, function (instance:Instance) {
				var path:LibraryPath;
				if (instance.libraryItem.linkageExportForAS) {
					path = PREFIX_LINKAGED_ELEMENT + instance.libraryItem.linkageClassName;
				} else {
					path = instance.libraryItem.name;
				}
				
				var data:FlatomoElement = { libraryPath: path };
				instance.setPersistentData(FIELD_NAME_ELEMENT, "string", Serializer.run(data));
				instance.setPublishPersistentData(FIELD_NAME_ELEMENT, "_EMBED_SWF_", true);
			});
		});
	}
	
	/** Timelineに存在するすべてのElementを走査します。 */
	@:loop(Timeline, Element)
	public static function loop_allElement(timeline:Timeline, loop:Element -> Void):Void {
		for (layer in timeline.layers) {
			for (frame in layer.frames) {
				for (element in frame.elements) {
					loop(element);
				}
			}
		}
	}
	
	/** Timelineに存在するすべてのInstanceを操作します。 */
	@:loop(Timeline, Instance)
	public static function loop_allInstance(timeline:Timeline, loop:Instance -> Void):Void {
		loop_allElement(timeline, function (element:Element) {
			if (Std.is(element, Instance)) {
				loop(cast(element, Instance));
			}
		});
	}
	
	/** ライブラリ項目のうち、SymbolItemだけを走査します。 */
	@:loop(Library, SymbolItem)
	public static function loop_allSymbolItem(library:Library, loop:SymbolItem -> Void):Void {
		for (item in library.items) {
			if (!StringTools.startsWith(item.name, FLATOMO_SETTINGS_DIRECTORY_NAME) && Std.is(item, SymbolItem)) {
				loop(cast(item, SymbolItem));
			}
		}
	}
	
	
	#end
	
}
