package ;

import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Lib.fl;

@:keep
class Script {
	
	public static function main() { trace("Extension"); }
	
	public static function invoke(command_raw:String):Serialization {
		return switch ((Unserializer.run(command_raw)):ScriptApi) {
			case ScriptApi.ValidationTest :
				return Serializer.run(false);
		}
	}
	
}
