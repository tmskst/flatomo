package flatomo;

import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
import jsfl.BitmapItem;
import jsfl.FLfile;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.Library;
import jsfl.SpriteSheetExporter;
import jsfl.SymbolItem;

using Lambda;
using jsfl.util.LibraryUtil;
using flatomo.util.SymbolItemTools;
using flatomo.util.TimelineTools;

class Publisher {
	
	public static function publish(library:Library, publishProfile:PublishProfile):Void {
		var filePath:String = publishProfile.publishPath + '/' + publishProfile.fileName;
		var structures:Map<String, Structure> = Parser.parse(library);
		
		publishTimeline(library, filePath);
		publishStructure(structures, filePath);
		publishAbstractDefinition(library, structures, publishProfile.publishPath);
		publishTexture(library, structures, filePath);
	}
	
	// タイムライン
	// ////////////////////////////////////////////////////////////////////
	
	private static inline var TIMELINE_EXTENSION:String = 'timeline';
	
	private static function publishTimeline(library:Library, filePath:String):Void {
		var timelines = new Map<String, Timeline>();
		for (symbolItem in library.symbolItems()) {
			timelines.set(symbolItem.name, {
				sections: symbolItem.getExtendedItem().sections,
				markers : symbolItem.timeline.getMarkers(),
			});
		}
		FLfile.write(filePath + '.' + TIMELINE_EXTENSION, Serializer.run(timelines));
	}
	
	
	// ストラクチャ
	// ////////////////////////////////////////////////////////////////////
	
	private static inline var STRUCTURE_EXTENSION:String = 'structure';
	
	private static function publishStructure(structures:Map<String, Structure>, filePath:String):Void {
		FLfile.write(filePath + '.' + STRUCTURE_EXTENSION, Serializer.run(structures));
	}
	
	
	// テクスチャ
	// ////////////////////////////////////////////////////////////////////
	
	private static inline var TEXTURE_DIRECTORY_NAME:String = 'texture';
	
	/**
	 * 出力対象に指定されたすべての表示オブジェクトを再構築するために必要なテクスチャを出力する
	 * テクスチャは `publishPath/flaFileName/texture` に出力される
	 * @param fileUri `publishPath/flaFileName`
	 */
	private static function publishTexture(library:Library, structures:Map<String, Structure>, fileUri:String):Void {
		var items = new Array<Item>();
		for (key in structures.keys()) {
			var structure:Structure = structures.get(key);
			if (structure.match(Animation | Image)) {
				items.push(library.getItem(key));
			}
		}
		
		var textureDirectoryPath:String = fileUri + '/' + TEXTURE_DIRECTORY_NAME + '/';
		FLfile.createFolder(textureDirectoryPath);
		
		for (item in items) {
			switch (item.itemType) {
				case BITMAP :
					var bitmapItem:BitmapItem = cast item;
					bitmapItem.exportToFile(textureDirectoryPath + item.name + ".png", 1);
				case MOVIE_CLIP, GRAPHIC :
					var symbolItem:SymbolItem = cast item;
					symbolItem.exportToPNGSequence(textureDirectoryPath + item.name);
			}
		}
	}
	
	
	// abstract 定義
	// ////////////////////////////////////////////////////////////////////
	
	private static function publishAbstractDefinition(library:Library, structures:Map<String, Structure>, fileUri:String):Void {
		var getClassName = function (path:String):String {
			return path.substring(path.lastIndexOf('.') + 1);
		}
		
		var execute:Template -> { PACKAGE:String, CLASS_NAME:String } -> Void = function (template, context){
			var contents = template.execute(context);
			var path:String = fileUri + '/' + if (context.PACKAGE != "") ~/\./g.replace(context.PACKAGE, "/") + "/" else "";
			FLfile.createFolder(path);
			FLfile.write(path + '/' + context.CLASS_NAME + '.hx', contents);
		};
		
		var publishAnimationHxClass = execute.bind(new Template(Resource.getString('animation')), _);
		var publishContainerHxClass = execute.bind(new Template(Resource.getString('container')), _);
		var publishPartsAnimationHxClass = execute.bind(new Template(Resource.getString('partsAnimation')), _);
		
		for (key in structures.keys()) {
			var structure:Structure = structures.get(key);
			var symbolItem:SymbolItem = cast library.getItem(key);
			switch (structure) {
				case Structure.Animation :
					var context:Dynamic = {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : symbolItem.linkageClassName.substring(0, symbolItem.linkageClassName.lastIndexOf(".")),
						SECTIONS   : symbolItem.getExtendedItem().sections.map(function (s) return { NAME: s.name }),
					};
					publishAnimationHxClass(context);
				case Structure.Container(children) :
					var context:Dynamic = {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : symbolItem.linkageClassName.substring(0, symbolItem.linkageClassName.lastIndexOf(".")),
						SECTIONS   : symbolItem.getExtendedItem().sections.map(function (s) return { NAME: s.name } ),
						FIELDS     : children.map(function (c) return { NAME : c.instanceName } ),
					};
					publishContainerHxClass(context);
				case Structure.PartsAnimation :
					var context:Dynamic = {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : symbolItem.linkageClassName.substring(0, symbolItem.linkageClassName.lastIndexOf(".")),
						SECTIONS   : symbolItem.getExtendedItem().sections.map(function (s) return { NAME: s.name }),
					};
					publishPartsAnimationHxClass(context);
				case Structure.Image :
					
			}
		}
	}
}
