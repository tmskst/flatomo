package flatomo;

import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
import jsfl.BitmapItem;
import jsfl.FLfile;
import jsfl.Item;
import jsfl.Library;
import jsfl.SymbolItem;

using Lambda;
using jsfl.util.LibraryUtil;
using flatomo.util.SymbolItemTools;
using flatomo.util.TimelineTools;

class Publisher {
	
	public static function publish(library:Library, publishProfile:PublishProfile):Void {
		var filePath:String = publishProfile.publishPath + '/' + publishProfile.fileName;
		var structures:Map<String, Structure> = Parser.parse(library);
		
		FLfile.createFolder(publishProfile.publishPath + '/' + publishProfile.fileName);
		publishTimeline(library, publishProfile);
		publishStructure(structures, publishProfile);
		publishAbstractDefinition(library, structures, publishProfile);
		publishTexture(library, structures, publishProfile);
	}
	
	// タイムライン
	// ////////////////////////////////////////////////////////////////////
	
	private static inline var TIMELINE_FILE_NAME:String = 'a';
	private static inline var TIMELINE_EXTENSION:String = 'timeline';
	
	private static function publishTimeline(library:Library, profile:PublishProfile):Void {
		var timelines = new Map<String, Timeline>();
		for (symbolItem in library.symbolItems()) {
			timelines.set(symbolItem.name, 
				new Timeline(symbolItem.getExtendedItem().sections, symbolItem.timeline.getMarkers())
			);
		}
		FLfile.write(profile.publishPath + '/' + profile.fileName + '/' + TIMELINE_FILE_NAME + '.' + TIMELINE_EXTENSION, Serializer.run(timelines));
	}
	
	
	// ストラクチャ
	// ////////////////////////////////////////////////////////////////////
	
	private static inline var STRUCTURE_FILE_NAME:String = 'a';
	private static inline var STRUCTURE_EXTENSION:String = 'structure';
	
	private static function publishStructure(structures:Map<String, Structure>, profile:PublishProfile):Void {
		FLfile.write(profile.publishPath + '/' + profile.fileName + '/' + STRUCTURE_FILE_NAME + '.' + STRUCTURE_EXTENSION, Serializer.run(structures));
	}
	
	
	// テクスチャ
	// ////////////////////////////////////////////////////////////////////
	
	private static inline var TEXTURE_DIRECTORY_NAME:String = 'texture';
	
	/**
	 * 出力対象に指定されたすべての表示オブジェクトを再構築するために必要なテクスチャを出力する
	 * テクスチャは `publishPath/flaFileName/texture` に出力される
	 * @param fileUri `publishPath/flaFileName`
	 */
	private static function publishTexture(library:Library, structures:Map<String, Structure>, profile:PublishProfile):Void {
		var items = new Array<Item>();
		for (key in structures.keys()) {
			var structure:Structure = structures.get(key);
			if (structure.match(Animation(_) | Image(_))) {
				items.push(library.getItem(key));
			}
		}
		
		var textureDirectoryPath:String = profile.publishPath + '/' + profile.fileName + '/' + TEXTURE_DIRECTORY_NAME + '/';
		FLfile.createFolder(textureDirectoryPath);
		
		for (item in items) {
			var fileUri:String = textureDirectoryPath + item.name;
			var folderUri:String = fileUri.substring(0, fileUri.lastIndexOf('/'));
			switch (item.itemType) {
				case BITMAP :
					var bitmapItem:BitmapItem = cast item;
					FLfile.createFolder(folderUri);
					bitmapItem.exportToFile(fileUri + ".png", 1);
				case MOVIE_CLIP, GRAPHIC :
					var symbolItem:SymbolItem = cast item;
					FLfile.createFolder(folderUri);
					symbolItem.exportToPNGSequence(fileUri);
			}
		}
	}
	
	
	// abstract 定義
	// ////////////////////////////////////////////////////////////////////
	
	private static function publishAbstractDefinition(library:Library, structures:Map<String, Structure>, profile:PublishProfile):Void {
		// アイテムパスからクラス名を抽出
		var getClassName = function (path:String) {
			return path.substring(path.lastIndexOf('/') + 1);
		};
		// ライブラリアイテムからパッケージ名を抽出
		var getPackage = function (item:Item) {
			return item.linkageClassName.substring(0, item.linkageClassName.lastIndexOf("."));
		};
		// シンボルアイテムからセクション名の列挙を抽出
		var getSections = function (symbolItem:SymbolItem) {
			return symbolItem.getExtendedItem().sections.map(function (s) return { NAME: s.name } );
		};
		
		var publishAnimationHxClass:Dynamic -> Void = null;
		var publishContainerHxClass:Dynamic -> Void = null;
		var publishPartsAnimationHxClass:Dynamic -> Void = null;
		{ // initialize templates
			var execute:Template -> { PACKAGE:String, CLASS_NAME:String } -> Void = function (template, context) {
				var contents = template.execute(context);
				var directoryPath = profile.publishPath + '/' + profile.fileName + '/' + 'src' + if (context.PACKAGE != '') '/' + ~/\./g.replace(context.PACKAGE, '/') else '';
				FLfile.createFolder(directoryPath);
				FLfile.write(directoryPath + '/' + context.CLASS_NAME + '.hx', contents);
			};
			
			publishAnimationHxClass = execute.bind(new Template(Resource.getString('animation')), _);
			publishContainerHxClass = execute.bind(new Template(Resource.getString('container')), _);
			publishPartsAnimationHxClass = execute.bind(new Template(Resource.getString('partsAnimation')), _);
		}
		
		for (key in structures.keys()) {
			var structure:Structure = structures.get(key);
			var symbolItem:SymbolItem = cast library.getItem(key);
			switch (structure) {
				case Structure.Animation :
					publishAnimationHxClass(cast {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : getPackage(symbolItem),
						SECTIONS   : getSections(symbolItem),
					});
				case Structure.Container(children) :
					publishContainerHxClass(cast {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : symbolItem.linkageClassName.substring(0, symbolItem.linkageClassName.lastIndexOf(".")),
						SECTIONS   : getSections(symbolItem),
						FIELDS     : children.map(function (c) return { NAME : c.instanceName } ),
					});
				case Structure.PartsAnimation :
					publishPartsAnimationHxClass(cast {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : symbolItem.linkageClassName.substring(0, symbolItem.linkageClassName.lastIndexOf(".")),
						SECTIONS   : getSections(symbolItem),
					});
				case Structure.Image :
					
			}
		}
	}
}
