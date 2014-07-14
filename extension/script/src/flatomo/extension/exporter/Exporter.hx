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
		
		TextureAtlasExporter.export(symbolItems, outputDirectoryPath + sourceFileName);
		exportPostures(symbolItems);
		MarkerExporter.export(symbolItems, outputDirectoryPath + sourceFileName);
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
