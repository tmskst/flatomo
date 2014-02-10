package flatomo.extension;
import haxe.Serializer;

class Connector {
	
	private static inline var CONNECTION_NAME:String = "FLATOMO";
	private static inline var HANDSHAKE:String = "INITIALIZE";
	
	private static inline var SWF_PANEL_NAME:String = "Panel";
	private static inline var FLATOMO_INITIALIZE:String = "flatomo_initialized";
	
	#if flash
	private var path:String;
	private var destination:String;
	private var handler:IHandler;
	
	public function new(path:String, destination:String, handler:IHandler) {
		this.path = path;
		this.destination = destination;
		this.handler = handler;
		
		flash.external.ExternalInterface.addCallback(HANDSHAKE, initialize);
		flash.external.ExternalInterface.addCallback(CONNECTION_NAME, handler.handle);
		untyped __global__["adobe.utils.MMExecute"]('
			var global = ( function() { return this; } ).apply( null, [] );
			if (!("${FLATOMO_INITIALIZE}" in global)) {
				fl.getSwfPanel("${SWF_PANEL_NAME}").call("${HANDSHAKE}");
			}
		');
	}
	
	private function initialize():Void {
		untyped __global__["adobe.utils.MMExecute"]('var ${FLATOMO_INITIALIZE} = true;');
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "Commands/${path}")');
	}
	
	public function send(data:Dynamic):Void {
		var raw_data:String = Serializer.run(data);
		untyped __global__["adobe.utils.MMExecute"]('${destination}.handle("${raw_data}")');
	}
	
	#end
	#if js
	
	public static function send(data:Dynamic):Void {
		var panel:SwfPanel = untyped fl.getSwfPanel(SWF_PANEL_NAME);
		var raw_data:String = Serializer.run(data);
		panel.call(CONNECTION_NAME, raw_data);
	}
	#end
	
}
