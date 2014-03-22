package flatomo.extension;
import flatomo.extension.Exporter.Salt;
import flatomo.FlatomoItem;
import haxe.Template;

class Exporter {
	
	public static function export(data: { metadata:Map<LibraryPath, FlatomoItem> , libraryPaths:Map<String, LibraryPath> } ):Array<{ name:String, value:String }> {
		var externs = new Array<{ name:String, value:String }>();
		var template = new Template(AbstractTemplate.T);
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
		//if (~/^[0-9a-zA-Z\/]/.match(name)) {
			name = StringTools.urlEncode(name);
			name = ~/_/g.replace(name, "__");
			name = ~/%/g.replace(name, "_p");
		//}
		return ~/\//g.replace(name, "____");
	}
	
	private static function getFields(targetLibraryPath:String, libraryPaths:Map <String, LibraryPath>):Array<{ NAME:String , CLASS_NAME:String }> {
		var fields = new Array<{ NAME:String , CLASS_NAME:String }>();
		for (libraryPath in libraryPaths.keys()) {
			if (StringTools.startsWith(libraryPath, targetLibraryPath)) {
				var name = libraryPath.substring(libraryPath.indexOf("#") + 1);
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

typedef Salt = {
	var FULL_CLASS_NAME:String;
	var CLASS_NAME:String;
	var SUPER_CLASS_NAME:String;
	var FIELDS:Array<{ NAME:String , CLASS_NAME:String }>;
	var SECTIONS:Array<{ NAME:String }>;
}

class AbstractTemplate {
	public static var T:String = 
'
package ;
import ::SUPER_CLASS_NAME::;

private typedef FTextField = starling.text.TextField;

abstract ::CLASS_NAME::(::SUPER_CLASS_NAME::) to ::SUPER_CLASS_NAME:: {
	
	public function new(content:::SUPER_CLASS_NAME::) {
		this = content;
	}
	
	public function gotoAndPlay(section:::FULL_CLASS_NAME::SectionName, ?increment:Int = 0):Void {
		this.playhead.gotoAndPlay(untyped section, increment);
	}
	
	public function gotoAndStop(section:::FULL_CLASS_NAME::SectionName, ?increment:Int = 0):Void {
		this.playhead.gotoAndStop(untyped section, increment);
	}
	
	public var body(get, never):::SUPER_CLASS_NAME::;
	public function get_body():::SUPER_CLASS_NAME:: {
		return cast this;
	}
	
	::if (SUPER_CLASS_NAME == "flatomo.Container")::
	::foreach FIELDS::
	public var ::NAME::(get, never):::CLASS_NAME::;
	private function get_::NAME::():::CLASS_NAME:: {
		return untyped this.getChildByName("::NAME::");
	}
	::end::
	::end::
}

@:enum abstract ::CLASS_NAME::SectionName(String) {
	::foreach SECTIONS::
	var ::NAME:: = "::NAME::";
	::end::
}

';
}

/*
class ClassTemplate {
	public static var T:String = '
package ;
import ::SUPER_CLASS_NAME::;

class ::CLASS_NAME:: {
	
	public var content(default, null):::SUPER_CLASS_NAME::;

	public function new(content:::SUPER_CLASS_NAME::) {
		this.content = content;
	}
	
	public function gotoAndPlay(section:::FULL_CLASS_NAME::SectionName, ?increment:Int = 0):Void {
		content.playhead.gotoAndPlay(untyped section, increment);
	}
	
	public function gotoAndStop(section:::FULL_CLASS_NAME::SectionName, ?increment:Int = 0):Void {
		content.playhead.gotoAndStop(untyped section, increment);
	}
	
	::foreach FIELDS::
	public var ::NAME::(get, never):::CLASS_NAME::;
	private function ::NAME::_xyz():::CLASS_NAME:: {
		return content.getChildByName("::NAME::");
	}
	::end::
	
}

@:enum abstract ::CLASS_NAME::SectionName(String) {
	::foreach SECTIONS::
	var ::NAME:: = "::NAME::";
	::end::
}
';
}
*/
