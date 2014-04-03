package flatomo.extension;

import flatomo.FlatomoItem;
import flatomo.LibraryPath;
import haxe.Resource;
import haxe.Template;

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
}

class HxClassesCreator {
	
	public static function export(data: { metadata:Map<LibraryPath, FlatomoItem> , libraryPaths:Map<String, LibraryPath> } ):Array<{ name:String, value:String }> {
		var externs = new Array<{ name:String, value:String }>();
		var template = new Template(Resource.getString("template"));
		for (libraryPath in data.metadata.keys()) {
			var item = data.metadata.get(libraryPath);
			var salt:Salt = {
				CLASS_NAME	: "F" + getClassName(libraryPath),
				SUPER_CLASS_NAME	: if (item.animation) "flatomo.Animation" else "flatomo.Container",
				FIELDS		: getFields(libraryPath, data.libraryPaths),
				SECTIONS	: getSections(item),
				API_NAME	: if (item.animation) "animationApi" else "containerApi",
			}
			externs.push( { name: salt.CLASS_NAME, value: template.execute(salt) } );
		}
		return externs;
	}
	
	/**
	 * ライブラリパスからクラス名（型の名前）を抽出します
	 * @param	libraryPath ライブラリパス
	 * @return クラス名（型の名前）
	 */
	private static function getClassName(libraryPath:String):String {
		// 正規化したライブラリパスについて、後ろからはじめて現れるピリオドまで。
		var fqcn = getFQCN(libraryPath);
		return fqcn.substring(fqcn.lastIndexOf(".") + 1);
	}
	
	/** ライブラリパスを正規化します */
	private static function getFQCN(libraryPath:String):String {
		/*
		 * 1. PREFIX 'F:' を削除
		 * 2. URLエンコードされたライブラリパスについて
		 * 	1. '_' -> '__'
		 * 	2. '%' -> '_p'
		 * 	3. '/' -> '____'
		 */
		var name = ~/^F:/.replace(libraryPath, "");
			name = StringTools.urlEncode(name);
			name = ~/_/g.replace(name, "__");
			name = ~/%/g.replace(name, "_p");
		return ~/\//g.replace(name, "____");
	}
	
	/** フィールドを生成します */
	private static function getFields(targetLibraryPath:String, libraryPaths:Map<String, LibraryPath>):Fields {
		var fields = new Fields();
		for (libraryPath in libraryPaths.keys()) {
			// ライブラリパスを比較して自身の子のみを走査する
			if (StringTools.startsWith(libraryPath, targetLibraryPath)) {
				var instanceName = libraryPath.substring(libraryPath.indexOf("#") + 1);
				// インスタンス名が 'PREFIX : _FLATOMO_SYMBOL_INSTANCE_' のときは、
				// 子にアクセスできない（する必要がない）ためフィールドは作らない
				if (StringTools.startsWith(instanceName, "_FLATOMO_SYMBOL_INSTANCE_")) { continue; }
				var className = "F" + getClassName(libraryPaths.get(libraryPath));
				fields.push({ NAME : instanceName, CLASS_NAME : className }); 
			}
		}
		return fields;
	}
	
	/** ライブラリ項目のセクション情報からセクション名の列挙を抽出します */
	private static function getSections(item:FlatomoItem):Sections {
		var sections = new Sections();
		for (section in item.sections) {
			sections.push({ NAME : section.name });
		}
		return sections;
	}
}
