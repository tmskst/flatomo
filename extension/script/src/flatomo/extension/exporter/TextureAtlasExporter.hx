package flatomo.extension.exporter;
import jsfl.SpriteSheetExporter;
import jsfl.SymbolItem;

// FIXME : 1枚に収まりきらないスプライトシートの対応
class TextureAtlasExporter {
	
	/**
	 * スプライトシートの出力。
	 * SWFプロファイルに設定されたディレクトリに `flaファイル名 + (.png, .xml)` が出力される。
	 */
	public static function export(symbolItems:Array<SymbolItem>, outputPath:String):Void {
		var exporter = new SpriteSheetExporter();
		{ // initialize SpriteSheetExporter
			exporter.algorithm = SpriteSheetExporterAlgorithm.MAX_RECTS;
			exporter.stackDuplicateFrames = true;
			exporter.allowTrimming = true;
			exporter.layoutFormat = cast "Flatomo";
			exporter.borderPadding = 2;
		}
		
		// シンボルアイテムをエクスポータに追加
		for (symbolItem in symbolItems) {
			exporter.addSymbol(symbolItem);
		}
		
		// スプライトシートを出力
		var imageFormat = { format: "png", bitDepth: 32, backgroundColor: "#00000000" };
		exporter.exportSpriteSheet(outputPath, imageFormat, true);
	}
	
}
