package flatomo;

import jsfl.Item;
import jsfl.ItemType;
import jsfl.Library;
import jsfl.SpriteSheetExporter;

using flatomo.util.LibraryTools;

class Publisher {
	
	public static function publish(library:Library, structures:Map<String, Structure>, publishProfile:PublishProfile):Void {
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
