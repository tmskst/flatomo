package flatomo.extension;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flatomo.extension.ScriptApi;
import haxe.Unserializer;

class Panel implements IHandler extends Sprite {
	
	public static function main() {
		Lib.current.stage.addChild(new Panel());
	}
	
	private var connector:Connector;
	
	public function new() {
		super();
		this.connector = new Connector("flatomo.jsfl", "flatomo.extension.Script", this);
		Lib.current.stage.addEventListener(MouseEvent.CLICK, onClicked);
	}
	
	private function onClicked(event:Event):Void {
		this.connector.send(ScriptApi.hoge(120, "Hello"));
	}
	
	public function handle(raw_data:String):Void {
		var data:PanelApi = Unserializer.run(raw_data);
		switch (data) {
			case PanelApi.foobar(value) :
				trace(value);
		}
	}
	
}
