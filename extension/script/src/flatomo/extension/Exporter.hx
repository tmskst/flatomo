package flatomo.extension;

import flatomo.FlatomoItem;
import flatomo.ItemPath;
import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
import jsfl.FLfile;
import jsfl.LayerType;
import jsfl.Lib;
import jsfl.Lib.fl;
import jsfl.SpriteSheetExporter;
import jsfl.SymbolItem;

using jsfl.TimelineTools;
using flatomo.extension.ItemTools;

private typedef LayerName = String;
private typedef Marker = {
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var rotation:Float;
	var scaleX:Float;
	var scaleY:Float;
};

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
		exporter.borderPadding = 2;
		
		extendedItems = new Map<ItemPath, FlatomoItem>();
		postures = new Map<ItemPath, Posture>();
		markers = new Map<ItemPath, Map<LayerName, Map<Int, Marker>>>();
		
		var document = fl.getDocumentDOM();
		var library = document.library;
		for (item in library.items) {
			var flatomoItem = item.getFlatomoItem();
			if (flatomoItem != null && flatomoItem.animation) {
				analyzeItem(cast item);
			}
		}
		
		var outputDirectoryPath:String, sourceFileName:String;
		{ // outputDirectoryPath, sourceFileName を初期化
			var swfPath = document.getSWFPathFromProfile();
			outputDirectoryPath = swfPath.substring(0, swfPath.lastIndexOf("/")) + "/";
			if (packageName != "") {
				outputDirectoryPath += ~/\./g.replace(packageName, "/")  + "/";
			}
			var path = swfPath.substring(0, swfPath.lastIndexOf("."));
			sourceFileName = path.substring(path.lastIndexOf("/") + 1);
			FLfile.createFolder(outputDirectoryPath);
		}
		
		{ // *.pos を書き出す
			FLfile.write(outputDirectoryPath + sourceFileName + ".pos", Serializer.run(postures));
		}
		
		{ // *.mks を書き出す
			FLfile.write(outputDirectoryPath + sourceFileName + ".mks", Serializer.run(markers));
		}
		
		{ // スプライトシートの書き出し
			var imageFormat = { format: "png", bitDepth: 32, backgroundColor: "#00000000" };
			exporter.exportSpriteSheet(outputDirectoryPath + sourceFileName, imageFormat, true);
		}
		
		{ // extern定義（*.hx）を書き出す
			var files = HxClassesCreator.export2(extendedItems, packageName);
			for (file in files) {
				FLfile.write(outputDirectoryPath + file.name + ".hx", file.value);
			}
		}
		
		{ // ExtendedItems の列挙
			var salt = { ENUM_NAME: sourceFileName, EXTENDED_ITEMS: extendedItems.keys(), PACKAGE: packageName };
			FLfile.write(outputDirectoryPath + sourceFileName + "Items.hx", new Template(Resource.getString("template_enum")).execute(salt));
		}
		
	}
	
	private var exporter:SpriteSheetExporter;
	private var extendedItems:Map<ItemPath, FlatomoItem>;
	private var postures:Map<ItemPath, Posture>;
	private var markers:Map<ItemPath, Map<LayerName, Map<Int, Marker>>>;
	
	private function analyzeItem(symbolItem:SymbolItem):Void {
		var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
		// TODO : Publisher.hx L77
		if (extendedItem == null) {
			var sections = SectionCreator.fetchSections(symbolItem.timeline);
			extendedItem = { sections: sections, animation: false };
		}
		
		exporter.addSymbol(symbolItem);
		var extendedItemPath = symbolItem.name.split("/").pop();
		extendedItems.set(extendedItemPath, extendedItem);
		
		var unionBounds = TimelineTools.getUnionBounds(symbolItem.timeline, false, false);
		postures.set(extendedItemPath, Posture.Animation(extendedItem.sections, Math.ceil(-unionBounds.left), Math.ceil(-unionBounds.top)));
		fl.trace(Math.ceil( -unionBounds.left));
		fl.trace(Math.ceil( -unionBounds.top));
		
		
		var m1 = new Map<LayerName, Map<Int, Marker>>();
		
		for (layer in symbolItem.timeline.layers) {
			if (layer.layerType == LayerType.GUIDE && StringTools.startsWith(layer.name, "marker_")) {
				var m2 = new Map<Int, Marker>();
				for (f in 0...layer.frameCount) {
					var frame = layer.frames[f];
					for (element in frame.elements) {
						var marker:Marker = {
							x: element.x, y: element.y,
							width: element.width, height: element.height,
							rotation: element.rotation,
							scaleX: element.scaleX, scaleY: element.scaleY,
						};
						m2.set(f, marker);
					}
				}
				m1.set(layer.name, m2);
			}
		}
		markers.set(symbolItem.name, m1);
	}
	
}
