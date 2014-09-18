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
using flatomo.util.LibraryTools;
using flatomo.util.SymbolItemTools;

class Publisher {
	
	public static function publish(library:Library, structures:Map<String, Structure>, publishProfile:PublishProfile):Void {
		
		// Section
		// ////////////////////////////////////////////////////////////////////
		var sections = new Map<String, Array<Section>>();
		
		for (item in library.items) {
			switch (item.itemType) {
				case ItemType.MOVIE_CLIP, ItemType.GRAPHIC :
					var symbolItem:SymbolItem = cast item;
					var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
					sections.set(item.name, extendedItem.sections);
			}
		}
		FLfile.write(publishProfile.publishPath + '/' + publishProfile.fileName + '.' + 'tim', Serializer.run(sections));
		
		// Section
		// ////////////////////////////////////////////////////////////////////
		FLfile.write(publishProfile.publishPath + '/' + publishProfile.fileName + '.' + 'pos', Serializer.run(structures));
		
		
		// HxClasses
		// ////////////////////////////////////////////////////////////////////
		var getClassName = function (path:String):String {
			return path.substring(path.lastIndexOf('.') + 1);
		}
		
		var templateAnimation = new Template(Resource.getString('animation'));
		var templateContainer = new Template(Resource.getString('container'));
		
		for (key in structures.keys()) {
			var structure:Structure = structures.get(key);
			switch (structure) {
				case Structure.Animation :
					var symbolItem:SymbolItem = cast library.getItem(key);
					var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
					var context = {
						KEY        : key,
						CLASS_NAME : getClassName(symbolItem.name),
						PACKAGE    : symbolItem.linkageClassName.substring(0, symbolItem.linkageClassName.lastIndexOf(".")),
						SECTIONS   : extendedItem.sections.map(function (s) return { NAME: s.name }),
					};
					
					var contents = templateAnimation.execute(context);
					
					var path:String = if (context.PACKAGE != "") ~/\./g.replace(context.PACKAGE, "/") + "/" else "";
					FLfile.createFolder(publishProfile.publishPath + '/' + path);
					FLfile.write(publishProfile.publishPath + '/' + path + '/' + context.CLASS_NAME + ".hx", contents);
					
				case Structure.Container :
				case Structure.PartsAnimation :
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
	
}