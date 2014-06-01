package flatomo.extension;

import flatomo.FlatomoItem;
import flatomo.ItemPath;
import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
import haxe.Unserializer;
import jsfl.FLfile;
import jsfl.Lib;
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
		var packageName:String = Lib.prompt("PACKAGE-NAME");
		if (packageName == null) { packageName = ""; }
		
		exporter = new SpriteSheetExporter();
		exporter.algorithm = SpriteSheetExporterAlgorithm.MAX_RECTS;
		exporter.layoutFormat = SpriteSheetExporterLayoutFormat.STARLING;
		
		extendedItems = new Map<ItemPath, FlatomoItem>();
		
		var template = new Template(Resource.getString("template_enum"));
		
		var document = fl.getDocumentDOM();
		var library = document.library;
		for (item in library.items) {
			var flatomoItem = item.getFlatomoItem();
			if (flatomoItem != null && flatomoItem.animation) {
				analyzeItem(cast item);
			}
		}
		
		var outputDirectoryPath:String, sourceFileName:String;
			var swfPath = document.getSWFPathFromProfile();
		{
			outputDirectoryPath = swfPath.substring(0, swfPath.lastIndexOf("/")) + "/";
			if (packageName != "") {
				outputDirectoryPath += ~/\./g.replace(packageName, "/")  + "/";
			}
			var path = swfPath.substring(0, swfPath.lastIndexOf("."));
			sourceFileName = path.substring(path.lastIndexOf("/") + 1);
		}
		FLfile.createFolder(outputDirectoryPath);
		
		{ // *.postures を書き出す
			var postures = new Map<ItemPath, Posture>();
			for (key in extendedItems.keys()) {
				var extendedItem:FlatomoItem = extendedItems.get(key);
				postures.set(key, Posture.Animation(extendedItem.sections, 0, 0));
			}
			FLfile.write(outputDirectoryPath + sourceFileName + ".pos", Serializer.run(postures));
		}
		
		{ 
			var imageFormat = { format: "png", bitDepth: 32, backgroundColor: "#00000000" };
			exporter.exportSpriteSheet(outputDirectoryPath + sourceFileName, imageFormat, true);
		}
		
		{ // extern定義（*.hx）を書き出す
			var files = HxClassesCreator.export2(extendedItems, packageName);
			for (file in files) {
				FLfile.write(outputDirectoryPath + file.name + ".hx", file.value);
			}
		}
		
		{
			var salt = { ENUM_NAME: sourceFileName, EXTENDED_ITEMS: extendedItems.keys(), PACKAGE: packageName };
			FLfile.write(outputDirectoryPath + sourceFileName + "Items.hx", template.execute(salt));
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
