package flatomo.extension;

import com.bit101.components.PushButton;
import com.bit101.components.Style;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;

class ExtensionPanel extends Sprite {
	
	public static function main() {
		Style.setStyle(Style.DARK);
		Lib.current.stage.addChild(new ExtensionPanel());
	}
	
	public function new() {
		super();
		
		openSymbolItemConfigButton = new PushButton(this, 10, 20, "OPEN SYMBOL ITEM CONFIG", openSymbolItemConfig);
		openSymbolItemConfigButton.height = 20;
		
		publishButton = new PushButton(this, 10, 40, "PUBLISH", publish);
		publishButton.height = 20;
		
		openDocumentConfigButton = new PushButton(this, 10, 60, "OPEN DOCUMENT CONFIG", openDocumentConfig);
		openDocumentConfigButton.height = 20;
		
		resize(null);
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	
	private var openSymbolItemConfigButton:PushButton;
	private var publishButton:PushButton;
	private var openDocumentConfigButton:PushButton;
	
	private function resize(event:Event = null):Void {
		var stageWidth = Lib.current.stage.stageWidth;
		var stageHeight = Lib.current.stage.stageHeight;
		
		openSymbolItemConfigButton.width = stageWidth - 20;
		publishButton.width = stageWidth - 20;
		openDocumentConfigButton.width = stageWidth - 20;
	}
	
	private function openSymbolItemConfig(event:Event):Void {
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "WindowSWF/FlatomoItemConfig.jsfl")');
	}
	
	private function publish(event:Event):Void {
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "WindowSWF/PublishDialog.jsfl")');
	}
	
	private function openDocumentConfig(event:Event):Void {
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "WindowSWF/DocumentConfig.jsfl")');
	}
	
}
