package flatomo.extension;

import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.Style;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import haxe.macro.Compiler;

class ExtensionPanel extends Sprite {
	
	public static function main() {
		Style.setStyle(Style.DARK);
		Lib.current.stage.addChild(new ExtensionPanel());
	}
	
	public function new() {
		super();
		
		flatomoVersionLabel = new Label(this, 0, 65, Compiler.getDefine("flatomoVersion"));
		
		openFlatomoItemConfigDialogButton = new PushButton(this, 10, 5, "OPEN SYMBOL ITEM CONFIG", openSymbolItemConfig);
		openFlatomoItemConfigDialogButton.height = 20;
		
		openPublishDialogButton = new PushButton(this, 10, 25, "PUBLISH", publish);
		openPublishDialogButton.height = 20;
		
		openDocumentConfigDialogButton = new PushButton(this, 10, 45, "OPEN DOCUMENT CONFIG", openDocumentConfig);
		openDocumentConfigDialogButton.height = 20;
		
		resize(null);
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	
	private var flatomoVersionLabel:Label;
	private var openFlatomoItemConfigDialogButton:PushButton;
	private var openPublishDialogButton:PushButton;
	private var openDocumentConfigDialogButton:PushButton;
	
	private function resize(event:Event = null):Void {
		var buttonWidth = Lib.current.stage.stageWidth - 20;
		
		flatomoVersionLabel.x = buttonWidth - flatomoVersionLabel.width + 10;
		openFlatomoItemConfigDialogButton.width = buttonWidth;
		openPublishDialogButton.width = buttonWidth;
		openDocumentConfigDialogButton.width = buttonWidth;
	}
	
	private function openSymbolItemConfig(event:Event):Void {
		execute("WindowSWF/FlatomoItemConfig.jsfl");
	}
	
	private function publish(event:Event):Void {
		execute("WindowSWF/PublishDialog.jsfl");
	}
	
	private function openDocumentConfig(event:Event):Void {
		execute("WindowSWF/DocumentConfig.jsfl");
	}
	
	private function execute(fileName:String):Void {
		untyped __global__["adobe.utils.MMExecute"]('fl.runScript(fl.configURI + "$fileName")');
	}
	
}
