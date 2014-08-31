package flatomo.extension.exporter;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.SpriteSheetExporter;

// FIXME : 1枚に収まりきらないスプライトシートの対応
class TextureAtlasExporter {
	
	/**
	 * スプライトシートの出力。
	 * SWFプロファイルに設定されたディレクトリに `flaファイル名 + (.png, .xml)` が出力される。
	 */
	public static function export(items:Array<Item>, outputPath:String):Void {
		var exporter = new SpriteSheetExporter();
		{ // initialize SpriteSheetExporter
			exporter.algorithm = SpriteSheetExporterAlgorithm.MAX_RECTS;
			exporter.stackDuplicateFrames = true;
			exporter.allowTrimming = true;
			exporter.layoutFormat = cast "Flatomo";
			exporter.borderPadding = 2;
		}
		
		// シンボルアイテムをエクスポータに追加
		for (item in items) {
			switch (item.itemType) {
				case ItemType.BITMAP :
					exporter.addBitmap(cast item);
				case ItemType.MOVIE_CLIP, ItemType.GRAPHIC :
					exporter.addSymbol(cast item);
			}
		}
		
		// スプライトシートを出力
		var imageFormat = { format: "png", bitDepth: 32, backgroundColor: "#00000000" };
		exporter.exportSpriteSheet(outputPath, imageFormat, true);
	}
	
}
