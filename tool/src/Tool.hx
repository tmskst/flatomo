package ;

import flash.desktop.NativeApplication;
import flash.events.InvokeEvent;
import haxe.Unserializer;

class Tool {
	
	public static function main() {
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, initialize);
	}
	
	private static function initialize(event:InvokeEvent):Void {
		var config:Config = Unserializer.run(event.arguments[0]);
		trace(config);
		NativeApplication.nativeApplication.exit(0);
	}
	
}
