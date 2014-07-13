package flatomo.extension;

import com.bit101.components.PushButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class ExtensionPanel extends Sprite {
	
	public static function main() {
		Lib.current.stage.addChild(new ExtensionPanel());
	}
	
	public function new() {
		super();
		openSymbolItemConfigButton = new PushButton(this, 0, 0, "OPEN SYMBOL ITEM CONFIG", openSymbolItemConfig);
		openSymbolItemConfigButton.y = 20;
		openSymbolItemConfigButton.x = 10;
		openSymbolItemConfigButton.height = 20;
		resize(null);
	}
	
	private var openSymbolItemConfigButton:PushButton;
	
	private function resize(event:Event = null):Void {
		var stageWidth = Lib.current.stage.stageWidth;
		var stageHeight = Lib.current.stage.stageHeight;
		openSymbolItemConfigButton.width = stageWidth - 20;
	}
	
	private function openSymbolItemConfig(event:Event):Void {
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "WindowSWF/flatomo.jsfl")');
	}
	
}
