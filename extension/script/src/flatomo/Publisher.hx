package flatomo;

import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
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
		
		
		// HxClasses
		// ////////////////////////////////////////////////////////////////////
		var getClassName = function (path:String):String {
			return path.substring(path.lastIndexOf('.') + 1);
		}
		
		var execute:Template -> { PACKAGE:String, CLASS_NAME:String } -> Void = function (template, context){
			var contents = template.execute(context);
			var path:String = publishProfile.publishPath + '/' + if (context.PACKAGE != "") ~/\./g.replace(context.PACKAGE, "/") + "/" else "";
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
				case Structure.Container :
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
		
		
		
		// Textures
		// ////////////////////////////////////////////////////////////////////
		
		var textures = new Array<Item>();
		for (key in structures.keys()) {
			var structure:Structure = structures.get(key);
			switch (structure) {
				case Structure.Container(_) :
				case Structure.PartsAnimation(_) :
				// アニメーションかテクスチャ
				case Structure.Animation, Structure.Image :
					textures.push(library.getItem(key));
			}
		}
		
		// Publish
		// ////////////////////////////////////////////////////////////////////
		
		var spriteSheetExporter = new SpriteSheetExporter();
		{ // initialize
			spriteSheetExporter.stackDuplicateFrames = true;
			spriteSheetExporter.allowTrimming = true;
			spriteSheetExporter.layoutFormat = SpriteSheetExporterLayoutFormat.STARLING;
			spriteSheetExporter.borderPadding = 0;
		}
		
		for (texture in textures) {
			switch (texture.itemType) {
				case ItemType.BITMAP : 
					spriteSheetExporter.addBitmap(cast texture);
				case ItemType.MOVIE_CLIP, ItemType.GRAPHIC : 
					spriteSheetExporter.addSymbol(cast texture);
			}
		}
		
		var imageFormat = { format: "png", bitDepth: 32, backgroundColor: "#00000000" };
		spriteSheetExporter.exportSpriteSheet(publishProfile.publishPath + '/' + publishProfile.fileName, imageFormat, true);
	}
	
	private static function publishTimeline(library:Library, filePath:String):Void {
		var timelines = new Map<String, Timeline>();
		for (symbolItem in library.symbolItems()) {
			timelines.set(symbolItem.name, {
				sections: symbolItem.getExtendedItem().sections,
				markers : symbolItem.timeline.getMarkers(),
			});
		}
		FLfile.write(filePath + '.' + 'timeline', Serializer.run(timelines));
	}
	
	private static function publishStructure(structures:Map<String, Structure>, filePath:String):Void {
		FLfile.write(filePath + '.' + 'structure', Serializer.run(structures));
	}
	
}
