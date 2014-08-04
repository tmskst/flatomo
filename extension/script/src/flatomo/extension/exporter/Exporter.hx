package flatomo.extension.exporter;

import flatomo.extension.PartsAnimationParser;
import flatomo.extension.util.HxClassesCreator;
import flatomo.FlatomoItem.DisplayObjectType;
import haxe.Serializer;
import jsfl.Document;
import jsfl.FLfile;
import jsfl.ItemType;
import jsfl.Lib;
import jsfl.Library;
import jsfl.SymbolItem;

using Lambda;
using flatomo.extension.util.ItemTools;

class Exporter {
	
	public static function export(document:Document) {
		new Exporter(document);
	}
	
	public function new(document:Document) {
		var library:Library = document.library;
		
		var animationItems:Array<SymbolItem> = [];
		var containerItems:Array<SymbolItem> = [];
		
		for (item in library.items) {
			switch(item.itemType) {
				case ItemType.MOVIE_CLIP, ItemType.GRAPHIC :
					var symbolItem:SymbolItem = cast item;
					var flatomoItem:FlatomoItem = symbolItem.getFlatomoItem();
					if (symbolItem.linkageExportForAS && flatomoItem.exportForFlatomo) {
						switch (flatomoItem.displayObjectType) {
							case DisplayObjectType.Animation :
								animationItems.push(symbolItem);
							case DisplayObjectType.Container :
								containerItems.push(symbolItem);
						}
					}
			}
		}
		
		{ // outputDirectoryPath, sourceFileName を初期化
			var swfPath:String = document.getSWFPathFromProfile();
			outputDirectoryPath = swfPath.substring(0, swfPath.lastIndexOf("/")) + "/";
			var path:String = swfPath.substring(0, swfPath.lastIndexOf("."));
			sourceFileName = path.substring(path.lastIndexOf("/") + 1);
			var fileNameConvention:EReg = ~/^[A-Z][a-zA-Z0-9]+$/;
			if (!fileNameConvention.match(sourceFileName)) {
				return Lib.alert("不適切なSWFプロファイル設定 : 出力ファイル名は大文字で始まり、かつ使用できる文字は[a-zA-Z0-9]です。");
			}
			FLfile.createFolder(outputDirectoryPath);
		}
		
		
		var textureItems:Array<SymbolItem> = [];
		var materials = new Map<String, Array<{ name:String, matrixes:Array<Dynamic> }>>();
		
		for (containerItem in containerItems) {
			var parts = PartsAnimationParser.parse(containerItem);
			materials.set(containerItem.linkageClassName, parts.x);
			
			for (a in parts.y) {
				textureItems.push(cast a);
			}
			
			//for (part in parts) {
				//for (textureItem in textureItems) {
					//if (textureItem.name == part.name) { continue; }
				//}
				//var index = library.findItemIndex(part.name);
				//trace(Type.getClassName(Type.getClass(index)));
				//textureItems.push(cast library.items[index]);
				///*
				//var exists:Bool = textureItems
					//.exists(function (textureItem) { return textureItem.name == part.name; } );
				//
				//if (!exists) {
					//textureItems.push(cast library.items[library.findItemIndex(part.name)]);
				//}
				//*/
			//}
		}
		var outputPath:String = outputDirectoryPath + sourceFileName;
		FLfile.write(outputPath + "." + "mtl", Serializer.run(materials));
		
		TextureAtlasExporter.export(cast animationItems.concat(textureItems), outputPath);
		
		var staticExportItems = animationItems.concat(containerItems);
		
		MarkerExporter.export(staticExportItems, outputPath);
		exportPostures(staticExportItems);
		exportExterns(staticExportItems);
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
		var files = HxClassesCreator.create2(symbolItems);
		for (file in files) {
			var path:String = if (file.packageName != "") ~/\./g.replace(file.packageName, "/") + "/" else "";
			FLfile.createFolder(outputDirectoryPath + path);
			FLfile.write(outputDirectoryPath + path + file.name + ".hx", file.content);
		}
	}
	
}
