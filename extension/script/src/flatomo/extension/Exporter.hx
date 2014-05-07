package flatomo.extension;

import flatomo.FlatomoItem;
import flatomo.ItemPath;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.FLfile;
import jsfl.Lib.fl;
import jsfl.SpriteSheetExporter;
import jsfl.SymbolItem;

using jsfl.TimelineTools;
using flatomo.extension.ItemTools;

class Exporter {

	public static function main() {
		new Exporter();
	}
	
	public function new() {
		exporter = new SpriteSheetExporter();
		exporter.algorithm = SpriteSheetExporterAlgorithm.MAX_RECTS;
		exporter.layoutFormat = SpriteSheetExporterLayoutFormat.STARLING;
		
		extendedItems = new Map<ItemPath, FlatomoItem>();
		
		var document = fl.getDocumentDOM();
		var library = document.library;
		for (item in library.getSelectedItems()) {
			analyzeItem(cast item);
		}
		
		var swfPath:String = document.getSWFPathFromProfile();
		{ // *.postures を書き出す
			var postures = new Map<ItemPath, Posture>();
			for (key in extendedItems.keys()) {
				var extendedItem:FlatomoItem = extendedItems.get(key);
				postures.set(key, Posture.Animation(extendedItem.sections, 0, 0));
			}
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf(".")) + "." + "postures";
			FLfile.write(fileUri, Serializer.run(postures));
		}
		{ 
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf("."));
			exporter.exportSpriteSheet(fileUri,  { format: "png", bitDepth: 32, backgroundColor: "#00000000" }, true);
		}
		{ // extern定義（*.hx）を書き出す
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf("/"));
			var files = HxClassesCreator.export2(extendedItems);
			for (file in files) {
				FLfile.write(fileUri + "/" + file.name + ".hx", file.value);
			}
		}
		
		fl.trace("FIN");
	}
	
	private var exporter:SpriteSheetExporter;
	private var extendedItems:Map<ItemPath, FlatomoItem>;
	
	private function analyzeItem(symbolItem:SymbolItem):Void {
		var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
		// TODO : Publisher.hx L77
		if (extendedItem == null) {
			var sections = SectionCreator.fetchSections(symbolItem.timeline);
			extendedItem = { sections: sections, animation: false };
		}
		
		if (!extendedItem.animation) {
			throw ("#1 スプライトシート書き出しに指定するアイテムはアニメーション属性が有効でなければなりません。");
		}
		
		exporter.addSymbol(symbolItem);
		extendedItems.set(symbolItem.name.split("/").pop(), extendedItem);
	}
	
}
