package flatomo.extension;
import haxe.Serializer;

class Connector {
	
	private static inline var CONNECTION_NAME:String = "FLATOMO";
	
	#if flash
	private var destination:String;
	
	public function new(path:String, name:String, handler:IHandler) {
		this.destination = name;
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "Commands/${path}")');
		flash.external.ExternalInterface.addCallback(CONNECTION_NAME, handler.handle);
	}
	
	public function send(data:Dynamic):Void {
		var raw_data:String = Serializer.run(data);
		untyped __global__["adobe.utils.MMExecute"]('${destination}.handle("${raw_data}")');
	}
	
	#end
	#if js
	
	public static function send(swfPanelName:String, data:Dynamic):Void {
		var panel:SwfPanel = untyped fl.getSwfPanel(swfPanelName);
		var raw_data:String = Serializer.run(data);
		panel.call(CONNECTION_NAME, raw_data);
	}
	#end
	
}