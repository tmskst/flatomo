package flatomo.extension;

import flatomo.FlatomoItem;
import flatomo.ItemPath;
import flatomo.Marker;
import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
import jsfl.Element;
import jsfl.FLfile;
import jsfl.LayerType;
import jsfl.Lib.fl;
import jsfl.SpriteSheetExporter;
import jsfl.SymbolItem;

using jsfl.TimelineTools;
using flatomo.extension.ItemTools;

using Lambda;

class Exporter {

	public static function main() {
		new Exporter();
	}
	
	private function new() {
		/*
		 * このスクリプトでは
		 * スプライトシート、マーカー情報、アニメーションのextern定義、アニメーションの列挙を出力する。
		 */
		
		//var packageName:String = Lib.prompt("PACKAGE-NAME");
		//if (packageName == null) { packageName = ""; }
		
		var document = fl.getDocumentDOM();
		var library = document.library;
		
		var symbolItems = new Array<SymbolItem>();
		for (item in library.items) {
			// item は symbolItemでない可能性
			var flatomoItem = item.getFlatomoItem();
			if (flatomoItem != null && flatomoItem.animation) {
				symbolItems.push(cast item);
			}
		}
		
		{ // outputDirectoryPath, sourceFileName を初期化
			var swfPath = document.getSWFPathFromProfile();
			outputDirectoryPath = swfPath.substring(0, swfPath.lastIndexOf("/")) + "/";
			//if (packageName != "") {
				//outputDirectoryPath += ~/\./g.replace(packageName, "/")  + "/";
			//}
			var path = swfPath.substring(0, swfPath.lastIndexOf("."));
			sourceFileName = path.substring(path.lastIndexOf("/") + 1);	
			FLfile.createFolder(outputDirectoryPath);
		}
		
		exportSpriteSheet(symbolItems);
		exportPostures(symbolItems);
		exportMarkers(symbolItems);
		exportExterns(symbolItems);
		exportItemKind(symbolItems);
	}
	
	/**
	 * SWFの出力ディレクトリへのパス。
	 * パブリッシュ設定のFlash(.swf)プロファイルから得られる`出力ファイル`からファイル名を除いたもの。
	 * 例えば、`file:///C|/prj/flatomo-demo/res/library/` など。
	 */
	private var outputDirectoryPath:String;
	
	/**
	 * 出力されるSWFファイルの名前。
	 * パブリッシュ設定のFlash(.swf)プロファイルから得られる`出力ファイル`で設定されたファイル名。
	 * 例えば、`library`など。拡張子は含まれない。
	 */
	private var sourceFileName:String;
	
	private static inline var EXTENSION_POSTURES = "pos";
	private static inline var EXTENSION_MARKERS = "mks";
	private static inline var PREFIX_MARKER_LAYER_NAME = "marker_";
	
	// FIXME : 1枚に収まりきらないスプライトシートの対応
	/**
	 * スプライトシートの出力。
	 * SWFプロファイルに設定されたディレクトリに `flaファイル名 + (.png, .xml)` が出力される。
	 */
	private function exportSpriteSheet(items:Array<SymbolItem>):Void {
		var spriteSheetExporter = new SpriteSheetExporter();
		{ // 初期化
			spriteSheetExporter.algorithm		= SpriteSheetExporterAlgorithm.MAX_RECTS;
			spriteSheetExporter.layoutFormat	= SpriteSheetExporterLayoutFormat.STARLING;
			spriteSheetExporter.borderPadding	= 2;
		}
		
		// 書き出し対象のアイテムをエクスポーターに追加
		for (item in items) {
			spriteSheetExporter.addSymbol(item);
		}
		
		// スプライトシートの書き出し
		var imageFormat = { format: "png", bitDepth: 32, backgroundColor: "#00000000" };
		spriteSheetExporter.exportSpriteSheet(outputDirectoryPath + sourceFileName, imageFormat, true);
	}
	
	/**
	 * 表示オブジェクトの再構築に必要な情報をファイルに出力する。
	 * これにはセクション情報、アニメーションの`pivotX`、`pivotY`が含まれる。
	 * SWFプロファイルに設定されたディレクトリに `flaファイル名 + .pos` が出力される。
	 */
	private function exportPostures(symbolItems:Array<SymbolItem>):Void {
		var postures = new Map<ItemPath, Posture>();
		// 初期化
		for (symbolItem in symbolItems) {
			// extendedItem は animation属性が有効なアイテムに限定される
			var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
			var extendedItemPath:String = symbolItem.name.split("/").pop();
			var unionBounds = TimelineTools.getUnionBounds(symbolItem.timeline, false, false);
			postures.set(extendedItemPath, Posture.Animation(extendedItem.sections, Math.ceil( -unionBounds.left), Math.ceil( -unionBounds.top)));
		}
		
		// 出力
		FLfile.write(outputDirectoryPath + sourceFileName + "." + EXTENSION_POSTURES, Serializer.run(postures));
	}
	
	// FIXME: マーカーが存在しない場合にはファイルを出力しないように。
	/**
	 * マーカー情報をファイルに出力する。
	 * SWFプロファイルに設定されたディレクトリに `flaファイル名 + .mks` が出力される。
	 */
	private function exportMarkers(symbolItems:Array<SymbolItem>):Void {
		var packedMarkers = new Map<ItemPath, Map<LayerName, Map<Int, Marker>>>();
		for (symbolItem in symbolItems) {
			var packedMarker = new Map<LayerName, Map<Int, Marker>>();
			var markerLayers = symbolItem.timeline.layers.filter(function (layer) {
				return	layer.layerType == LayerType.GUIDE &&
						StringTools.startsWith(layer.name, PREFIX_MARKER_LAYER_NAME);
			});
			for (markerLayer in markerLayers) {
				// マーカーが存在しないフレームもあり得る
				var markers = new Map<Int, Marker>();
				for (frameIndex in 0...markerLayer.frameCount) {
					var frame = markerLayer.frames[frameIndex];
					for (element in frame.elements) {
						markers.set(frameIndex, MarkerTools.fromElement(element));
					}
				}
				packedMarker.set(markerLayer.name, markers);
			}
			packedMarkers.set(symbolItem.name, packedMarker);
		}
		FLfile.write(outputDirectoryPath + sourceFileName + "." + EXTENSION_MARKERS, Serializer.run(packedMarkers));
	}
	
	// FIXME: 出力先をアニメーションのFQCNに変更する。
	/**
	 * アニメーションのextern定義を出力する。
	 */
	private function exportExterns(symbolItems:Array<SymbolItem>):Void {
		var extendedItems = new Map<ItemPath, FlatomoItem>();
		for (symbolItem in symbolItems) {
			// extendedItem は animation属性が有効なアイテムに限定される
			var extendedItemPath:String = symbolItem.name.split("/").pop();
			var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
			extendedItems.set(extendedItemPath, extendedItem);
		}
		
		var files = HxClassesCreator.export2(extendedItems, "");
		for (file in files) {
			FLfile.write(outputDirectoryPath + file.name + ".hx", file.value);
		}
	}
	
	private function exportItemKind(symbolItems:Array<SymbolItem>):Void {
		var extendedItems = new Map<ItemPath, FlatomoItem>();
		for (symbolItem in symbolItems) {
			// extendedItem は animation属性が有効なアイテムに限定される
			var extendedItemPath:String = symbolItem.name.split("/").pop();
			var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
			extendedItems.set(extendedItemPath, extendedItem);
		}
		
		var salt = {
			ENUM_NAME: sourceFileName,
			EXTENDED_ITEMS: extendedItems.keys(),
			PACKAGE: "",
		};
		FLfile.write(outputDirectoryPath + sourceFileName + "Items.hx", new Template(Resource.getString("template_enum")).execute(salt));
	}
}

private class MarkerTools {
	public static function fromElement(element:Element):Marker {
		return {
			x: element.x,
			y: element.y,
			width: element.width,
			height: element.height,
			rotation: element.rotation,
			scaleX: element.scaleX,
			scaleY: element.scaleY,
		};
	}
}
