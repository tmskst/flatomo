package ;

import flatomo.ExtensionLibrary;
import flatomo.util.DocumentTools;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Document;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.Lib.fl;
import jsfl.Library;

using Lambda;
using flatomo.util.DocumentTools;
using flatomo.util.LibraryTools;

class Script {
	
	public static function main() { trace("Extension"); }
	
	public static function invoke(command_raw:String):Serialization {
		return Serializer.run(execute(Unserializer.run(command_raw)));
	}
	
	private static function execute(command:ScriptApi):Dynamic {
		var document:Document = fl.getDocumentDOM();
		
		switch (command) {
			case ScriptApi.ValidationTest :
				return document != null && document.isFlatomo();
			case ScriptApi.GetExtensionLibrary :
				return document.library.symbolItems().map(function (item) return item.name);
		}
	}
	
}
