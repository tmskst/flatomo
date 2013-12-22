package flatomo.extension;
import haxe.Unserializer;

class Script {
	
	public static function main() {
		send = Connector.send.bind("Panel");
	}
	
	private static var send:Api -> Void;
	
	public static function handle(raw_data:String):Void {
		var data:ScriptApi = Unserializer.run(raw_data);
		switch (data) {
			case ScriptApi.hoge(value, name) :
				untyped fl.trace(value);
				untyped fl.trace(name);
				send(PanelApi.foobar(10));
		}
	}
	
}
