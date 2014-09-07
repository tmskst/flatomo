package ;

import flatomo.util.DocumentTools;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Document;
import jsfl.Lib.fl;

@:keep
class Script {
	
	public static function main() { trace("Extension"); }
	
	public static function invoke(command_raw:String):Serialization {
		return Serializer.run(execute(Unserializer.run(command_raw)));
	}
	
	private static function execute(command:ScriptApi):Dynamic {
		switch (command) {
			case ScriptApi.ValidationTest :
				var document:Document = fl.getDocumentDOM();
				return document != null && DocumentTools.isFlatomo(document);
		}
	}
	
}
