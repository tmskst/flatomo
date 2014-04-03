package flatomo.extension;

import flatomo.FlatomoItem;
import haxe.Resource;
import haxe.Template;

private typedef Salt = {
	var FULL_CLASS_NAME:String;
	var CLASS_NAME:String;
	var SUPER_CLASS_NAME:String;
	var FIELDS:Array<{ NAME:String , CLASS_NAME:String }>;
	var SECTIONS:Array<{ NAME:String }>;
}


class Exporter {
	
	public static function export(data: { metadata:Map<LibraryPath, FlatomoItem> , libraryPaths:Map<String, LibraryPath> } ):Array<{ name:String, value:String }> {
		var externs = new Array<{ name:String, value:String }>();
		var template = new Template(Resource.getString("template"));
		for (libraryPath in data.metadata.keys()) {
			var item = data.metadata.get(libraryPath);
			var salt:Salt = {
				FULL_CLASS_NAME : "F" + getClassName(libraryPath),
				CLASS_NAME : "F" + getClassName(libraryPath),
				SUPER_CLASS_NAME : if (item.animation) "flatomo.Animation" else "flatomo.Container",
				FIELDS : getFields(libraryPath, data.libraryPaths),
				SECTIONS : getSections(item)
			}
			externs.push( { name: salt.CLASS_NAME, value: template.execute(salt) } );
		}
		return externs;
	}
	
	private static function getClassName(libraryPath:String):String {
		var fqcn = getFQCN(libraryPath);
		return fqcn.substring(fqcn.lastIndexOf(".") + 1);
	}
	
	private static function getFQCN(libraryPath:String):String {
		var name = ~/^F:/.replace(libraryPath, "");
			name = StringTools.urlEncode(name);
			name = ~/_/g.replace(name, "__");
			name = ~/%/g.replace(name, "_p");
		return ~/\//g.replace(name, "____");
	}
	
	private static function getFields(targetLibraryPath:String, libraryPaths:Map <String, LibraryPath>):Array<{ NAME:String , CLASS_NAME:String }> {
		var fields = new Array<{ NAME:String , CLASS_NAME:String }>();
		for (libraryPath in libraryPaths.keys()) {
			if (StringTools.startsWith(libraryPath, targetLibraryPath)) {
				var name = libraryPath.substring(libraryPath.indexOf("#") + 1);
				if (StringTools.startsWith(name, "_FLATOMO_SYMBOL_INSTANCE_")) { continue; }
				var className = "F" + getClassName(libraryPaths.get(libraryPath));
				fields.push({ NAME : name, CLASS_NAME : className }); 
			}
		}
		return fields;
	}
	
	private static function getSections(item:FlatomoItem):Array<{ NAME:String }> {
		var sections = new Array<{ NAME:String }>();
		for (section in item.sections) {
			sections.push({ NAME : getClassName(section.name) });
		}
		return sections;
		
	}
}
