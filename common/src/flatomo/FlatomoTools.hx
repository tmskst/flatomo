package flatomo;

import haxe.ds.StringMap.StringMap;
import haxe.Serializer;
import haxe.Unserializer;

class FlatomoTools {
	
	private static inline var FIELD_NAME_ELEMENT:String = "f_element";
	private static inline var FIELD_NAME_LIBRARY:String = "f_library";
	private static inline var INSTANCE_NAME_CONFIG:String = "i_config";
	
	private static inline var PREFIX_LINKAGED_ELEMENT:String = "F:";
	
	#if flash
	
	// 対象（Element）のメタデータからFlatomoElementを取り出します
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
	
	// 対象（Instance)をインスタンス化するために使用されたライブラリパスを取り出します
	public static function fetchLibraryPath(instance:flash.display.DisplayObject):LibraryPath {
		return fetchElement(instance).libraryPath;
	}
	
	// 対象（Instance）をインスタンス化するために使用されたライブラリアイテムと関連付けられたFlatomoItemを取り出します
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
	
	@:allow(flatomo.Flatomo)
	private static function fetchLibrary(source:flash.display.DisplayObjectContainer):StringMap<FlatomoItem> {
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
	
	public static function setLibrary(data:StringMap<FlatomoItem>):Void {
		var flash:Flash = untyped fl;
		flash.getDocumentDOM().setPublishDocumentData("_EMBED_SWF_", true);
		
		var library:Library = flash.getDocumentDOM().library;
		var config_item:SymbolItem = cast(library.items[library.findItemIndex("Flatomo/Config")], SymbolItem);
		var config:Element = config_item.timeline.layers[0].frames[0].elements[0];
		if (config.hasPersistentData(FIELD_NAME_LIBRARY)) {
			config.removePersistentData(FIELD_NAME_LIBRARY);
		}
		config.setPersistentData(FIELD_NAME_LIBRARY, "string", Serializer.run(data));
		config.setPublishPersistentData(FIELD_NAME_LIBRARY, "_EMBED_SWF_", true);
	}
	
	public static function createLibrary(items:Array<Item>):Map < LibraryPath, FlatomoItem > {
		var flatomo_library:Map<LibraryPath, FlatomoItem> = new Map<LibraryPath, FlatomoItem>();
		
		for (item in items) {
			if (!StringTools.startsWith(item.name, "Flatomo") && Std.is(item, SymbolItem)) {
				var timeline:Timeline = cast(item, SymbolItem).timeline;
				var sections:Array<Section> = fetchSections(timeline);
				var libraryPath:String = if (item.linkageExportForAS) PREFIX_LINKAGED_ELEMENT + item.linkageClassName else item.name;
				
				flatomo_library.set(libraryPath, { sections: sections, animation: false } );
			}
		}
		
		return flatomo_library;
	}
	
	public static function fetchSections(timeline:Timeline):Array<Section> {
		var layers:Array<Layer> = timeline.layers.filter(
			function(layer:Layer):Bool { return layer.name == "FlatomoControlLayer"; }
		);
		
		if (layers.length == 0) {
			untyped fl.trace("コントロールレイヤーが見つかりません。");
			return [{ name: "anonymous", kind: SectionKind.Once, begin: 1, end: timeline.frameCount }];
		}
		
		if (layers.length != 1) {
			untyped fl.trace("複数のコントロールレイヤーが見つかりました。");
			return [];
		}
		
		var controlLayer:Layer = layers.shift();
		
		var frames:Array<Frame> = controlLayer.frames;
		var keyFrames:Array<Int> = new Array<Int>();
		for (i in 0...frames.length) {
			if (i == frames[i].startFrame) { keyFrames.push(i); }
		}
		keyFrames.push(controlLayer.frameCount);
		
		var sections:Array<Section> = new Array<Section>();
		for (i in 0...keyFrames.length - 1) {
			var frame:Frame = frames[keyFrames[i]];
			sections.push({ name: frame.name, kind: SectionKind.Once, begin: keyFrames[i] + 1, end: keyFrames[i + 1] });
		}
		
		return sections;
	}
	
	public static function setElement(items:Array<Item>):Void {
		for (item in items) {
			if (!StringTools.startsWith(item.name, "Flatomo") && Std.is(item, SymbolItem)) {
				var timeline:Timeline = cast(item, SymbolItem).timeline;
				for (layer in timeline.layers) {
					for (frame in layer.frames) {
						for (element in frame.elements) {
							if (Std.is(element, Instance)) {
								var instance:Instance = cast(element, Instance);
								
								var data:FlatomoElement = { libraryPath: instance.libraryItem.name };
								var raw_data:String = Serializer.run(data);
								instance.setPersistentData(FIELD_NAME_ELEMENT, "string", raw_data);
								instance.setPublishPersistentData(FIELD_NAME_ELEMENT, "_EMBED_SWF_", true);
							}
						}
					}
				}
			}
		}
	}
	
	#end
	
}
