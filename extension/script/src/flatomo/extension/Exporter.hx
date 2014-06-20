package flatomo.extension;

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
		var document = fl.getDocumentDOM();
		var library = document.library;
		
		var symbolItems = new Array<SymbolItem>();
		for (item in library.items) {
			// ActionScript用に書き出しが有効でかつアニメーション属性が有効なアイテムが書き出される。
			if (item.itemType == ItemType.MOVIE_CLIP) {
				var symbolItem:SymbolItem = cast item;
				var flatomoItem:FlatomoItem = symbolItem.getFlatomoItem();
				if (symbolItem.linkageExportForAS &&
					flatomoItem != null && flatomoItem.animation) {
					symbolItems.push(symbolItem);
				}
			}
		}
		
		{ // outputDirectoryPath, sourceFileName を初期化
			var swfPath = document.getSWFPathFromProfile();
			outputDirectoryPath = swfPath.substring(0, swfPath.lastIndexOf("/")) + "/";
			var path = swfPath.substring(0, swfPath.lastIndexOf("."));
			sourceFileName = path.substring(path.lastIndexOf("/") + 1);
			var fileNameConvention = ~/^[A-Z][a-z0-9]+$/;
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
		exportKey(symbolItems);
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
		/*
		 * マップのキーはアニメーションのアイテム名（名前）でFQCN（item.linkageClassName）やItemPath（item.name）ではない。
		 * 表示オブジェクトを再構築するときにGpuOperatorへ命令するキーと
		 * posturesのキー、スプライトシートのname属性（PREFIX）はすべて一致する必要があるが
		 * jsfl.SpriteSheetExporter.addSymbolメソッドがnameを受け付けない仕様が原因でこれを満たすことができない。
		 * 従ってスプライトシート書き出しの対象となるアニメーションは、そのアイテムの名前が識別子の役割を果たすため
		 * このアイテムの名前はユニークでなければならない。
		 */
		var postures = new Map<String, Posture>();
		// 初期化
		for (symbolItem in symbolItems) {
			var symbolItemName:String = symbolItem.name.split("/").pop();
			var extendedItem:FlatomoItem = symbolItem.getFlatomoItem();
			var unionBounds = TimelineTools.getUnionBounds(symbolItem.timeline, false, false);
			postures.set(symbolItemName, Posture.Animation(extendedItem.sections, Math.ceil( -unionBounds.left), Math.ceil( -unionBounds.top)));
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
	
	// TODO: キー列挙の出力先を検討する必要がある。flaファイルの名前空間が必要になる可能性がある。
	/**
	 * 表示オブジェクトの再構築をGpuOperatorに命令するためのキーの列挙を出力する。
	 */
	private function exportKey(symbolItems:Array<SymbolItem>):Void {
		var extendedItems = new Array<String>();
		for (symbolItem in symbolItems) {
			extendedItems.push(symbolItem.name.split("/").pop());
		}
		
		var context = {
			PACKAGE: "",
			ENUM_NAME: sourceFileName,
			EXTENDED_ITEMS: extendedItems,
		};
		var textToWrite = new Template(Resource.getString("template_enum")).execute(context);
		FLfile.write(outputDirectoryPath + sourceFileName + "Key.hx", textToWrite);
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
