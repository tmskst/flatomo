package flatomo.util;

import flatomo.ExtendedItem;
import flatomo.ItemPath;
import flatomo.Linkage;
import haxe.Resource;
import haxe.Template;
import jsfl.SymbolItem;

using flatomo.util.SymbolItemTools;

private typedef Fields = Array<{ NAME:String , CLASS_NAME:String }>;
private typedef Sections = Array<{ NAME:String }>;

private typedef Salt = {
	/* 型（abstract）の名前 */
	var CLASS_NAME:String;
	/* 基本型の名前（'flatomo.Animation' か'flatomo.Container'） */
	var SUPER_CLASS_NAME:String;
	/* 子（インスタンス名とその型の名前）の列挙 */
	var FIELDS:Fields;
	/* セクション */
	var SECTIONS:Sections;
	/* 基本型への参照を持つフィールド名（'animationApi' か'containerApi'） */
	var API_NAME:String;
	
	var PACKAGE:String;
}

class HxClassesCreator {
	
	public static function create2(symbolItems:Array<SymbolItem>):Array<{ name:String, packageName:String, content:String }> {
		var template = new Template(Resource.getString("template"));
		var externs = new Array<{ name:String, packageName:String, content:String }>();
		
		for (symbolItem in symbolItems) {
			var flatomoItem:ExtendedItem = symbolItem.getExtendedItem();
			var linkageClassName:Linkage = symbolItem.linkageClassName;
			var context = {
				KEY					: linkageClassName,
				CLASS_NAME			: HxClassesCreator.getClassName(linkageClassName),
				SUPER_CLASS_NAME	: "flatomo.display.Animation",
				SECTIONS			: HxClassesCreator.getSections(flatomoItem),
				API_NAME			: "animationApi",
				PACKAGE				: linkageClassName.substring(0, linkageClassName.lastIndexOf(".")),
			};
			externs.push({
				name:			context.CLASS_NAME,
				packageName:	context.PACKAGE,
				content:		template.execute(context),
			});
		}
		return externs;
	}
	
	/**
	 * ライブラリパスからクラス名（型の名前）を抽出します
	 * @param	itemPath ライブラリパス
	 * @return クラス名（型の名前）
	 */
	private static function getClassName(itemPath:String):String {
		// 正規化したライブラリパスについて、後ろからはじめて現れるピリオドまで。
		var fqcn = getFQCN(itemPath);
		return fqcn.substring(fqcn.lastIndexOf(".") + 1);
	}
	
	/** ライブラリパスを正規化します */
	private static function getFQCN(itemPath:String):String {
		/*
		 * 1. PREFIX 'F:' を削除
		 * 2. URLエンコードされたライブラリパスについて
		 * 	1. '_' -> '__'
		 * 	2. '%' -> '_p'
		 * 	3. '/' -> '____'
		 * 	4. '-' -> '_h'
		 */
		var name = ~/^F:/.replace(itemPath, "");
			name = StringTools.urlEncode(name);
			name = ~/_/g.replace(name, "__");
			name = ~/%/g.replace(name, "_p");
			name = ~/-/g.replace(name, "_h");
		return ~/\//g.replace(name, "____");
	}
	
	/** フィールドを生成します */
	private static function getFields(targetItemPath:String, itemPaths:Map<String, ItemPath>):Fields {
		var fields = new Fields();
		for (itemPath in itemPaths.keys()) {
			// ライブラリパスを比較して自身の子のみを走査する
			if (StringTools.startsWith(itemPath, targetItemPath)) {
				var instanceName = itemPath.substring(itemPath.indexOf("#") + 1);
				// インスタンス名が 'PREFIX : _FLATOMO_SYMBOL_INSTANCE_' のときは、
				// 子にアクセスできない（する必要がない）ためフィールドは作らない
				if (StringTools.startsWith(instanceName, "_FLATOMO_SYMBOL_INSTANCE_")) { continue; }
				var className = "F" + getClassName(itemPaths.get(itemPath));
				fields.push({ NAME : instanceName, CLASS_NAME : className }); 
			}
		}
		return fields;
	}
	
	/** ライブラリ項目のセクション情報からセクション名の列挙を抽出します */
	private static function getSections(item:ExtendedItem):Sections {
		var sections = new Sections();
		for (section in item.sections) {
			sections.push({ NAME : section.name });
		}
		return sections;
	}
}