package flatomo.extension.exporter;

import flatomo.extension.util.HxClassesCreator;
import flatomo.FlatomoItem;
import flatomo.ItemPath;
import flatomo.Marker;
import haxe.Resource;
import haxe.Serializer;
import haxe.Template;
import jsfl.Element;
import jsfl.FLfile;
import jsfl.ItemType;
import jsfl.LayerType;
import jsfl.Lib;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.SpriteSheetExporter;
import jsfl.SymbolItem;

using jsfl.TimelineTools;
using flatomo.extension.util.ItemTools;

using Lambda;

class Exporter {

	public static function run() {
		new Exporter();
	}
	
	private function new() {
		/*
		 * このスクリプトでは
		 * スプライトシート、マーカー情報、アニメーションのextern定義、アニメーションの列挙を出力する。
		 */
		var document = fl.getDocumentDOM();
		var library = document.library;
		
		var symbolItems = new Array<SymbolItem>();
		for (item in library.items) {
			// ActionScript用に書き出しが有効でかつアニメーション属性が有効なアイテムが書き出される。
			if (item.itemType == ItemType.MOVIE_CLIP) {
				var symbolItem:SymbolItem = cast item;
				var flatomoItem:FlatomoItem = symbolItem.getFlatomoItem();
				if (symbolItem.linkageExportForAS &&
					flatomoItem.exportForFlatomo &&
					flatomoItem.exportType.equals(ExportType.Static) &&
					flatomoItem.displayObjectType.equals(DisplayObjectType.Animation)) {
					symbolItems.push(symbolItem);
				}
			}
		}
		
		{ // outputDirectoryPath, sourceFileName を初期化
			var swfPath = document.getSWFPathFromProfile();
			outputDirectoryPath = swfPath.substring(0, swfPath.lastIndexOf("/")) + "/";
			var path = swfPath.substring(0, swfPath.lastIndexOf("."));
			sourceFileName = path.substring(path.lastIndexOf("/") + 1);
			var fileNameConvention = ~/^[A-Z][a-zA-Z0-9]+$/;
			if (!fileNameConvention.match(sourceFileName)) {
				Lib.alert("不適切なSWFプロファイル設定 : 出力ファイル名は大文字で始まり、かつ使用できる文字は[a-zA-Z0-9]です。");
				return;
			}
			FLfile.createFolder(outputDirectoryPath);
		}
		
		exportSpriteSheet(symbolItems);
		exportPostures(symbolItems);
		exportMarkers(symbolItems);
		exportExterns(symbolItems);
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
	 * Haxeがクラス名として許可する文字列のみがファイル名として許される。
	 * 例えば、`Library`など。拡張子は含まれない。
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
			spriteSheetExporter.stackDuplicateFrames = true;
			spriteSheetExporter.allowTrimming = true;
			// Flatomo.plugin.jsfl の name属性には`item.linkageExportForAS`が指定される
			spriteSheetExporter.layoutFormat	= cast "Flatomo";
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
		var postures = new Map<Linkage, Posture>();
		// 初期化
		for (symbolItem in symbolItems) {
			var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
			postures.set(symbolItem.linkageClassName, Posture.Animation(extendedItem.sections));
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
		var library:Library = fl.getDocumentDOM().library;
		for (symbolItem in symbolItems) {
			library.editItem(symbolItem.name);
			
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
					symbolItem.timeline.setSelectedFrames(frameIndex, frameIndex);
					for (element in frame.elements) {
						markers.set(frameIndex, MarkerTools.fromElement(element));
					}
				}
				packedMarker.set(markerLayer.name, markers);
			}
			packedMarkers.set(symbolItem.linkageClassName, packedMarker);
		}
		FLfile.write(outputDirectoryPath + sourceFileName + "." + EXTENSION_MARKERS, Serializer.run(packedMarkers));
	}
	
	// FIXME: 出力先をアニメーションのFQCNに変更する。
	/**
	 * アニメーションのextern定義を出力する。
	 */
	private function exportExterns(symbolItems:Array<SymbolItem>):Void {
		var files = HxClassesCreator.export2(symbolItems);
		for (file in files) {
			var path:String = if (file.packageName != "") ~/\./g.replace(file.packageName, "/") + "/" else "";
			FLfile.createFolder(outputDirectoryPath + path);
			FLfile.write(outputDirectoryPath + path + file.name + ".hx", file.content);
		}
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
