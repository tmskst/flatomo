package flatomo.extension;
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.Style;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flatomo.FlatomoItem;
import flatomo.Section;
import haxe.Unserializer;

using Lambda;

class ExtensionPanel extends Sprite implements IHandler {
	
	public static function main() {
		try {
			Lib.current.stage.addChild(new ExtensionPanel());
		} catch (error:Dynamic) {
			trace(error);
		}
	}
	
	private var connector:Connector;
	
	private var canvasHeader:Header;
	private var canvasContent:ContentViewer;
	
	public function new() {
		super();
		
		Style.embedFonts = false;
		Style.fontSize = 12;
		
		this.connector = new Connector("flatomo.jsfl", "flatomo.extension.Script", this);
		
		canvasContent = new ContentViewer(changed);
		canvasContent.y = 30;
		this.addChild(canvasContent);
		
		canvasHeader = new Header(function (event:Event):Void {
			connector.send(ScriptApi.Refresh);
		});
		this.addChild(canvasHeader);
	}
	
	// ------------------------------------------------------------------------------------
	
	public function handle(raw_data:String):Void {
		var data:PanelApi = Unserializer.run(raw_data);
		switch (data) {
			case PanelApi.Refresh(timelineName, latestSection, savedItem) :
				timlineSelected(timelineName, latestSection, savedItem);
			case PanelApi.TimlineSelected(timelineName, latestSection, savedItem) :
				timlineSelected(timelineName, latestSection, savedItem);
			case PanelApi.DisabledTimlineSelected :
				 disabledTimlineSelected();
			case PanelApi.FlatomoDisabled :
				flatomoDisabled();
		}
	}
	
	private function disabledTimlineSelected():Void {
		canvasContent.disabledTimlineSelected();
	}
	
	/**
	 * 作業中のドキュメントはFlatomoに対応していないか有効でない
	 */
	private function flatomoDisabled():Void {
		canvasContent.flatomoDisabled();
	}
	
	private function timlineSelected(timelineName:String, latestSection:Array<Section>, savedItem:Null<FlatomoItem>):Void {
		// セクションビュアーをすべて消去
		canvasContent.clear();
		
		// 最新のセクション情報と保存済みセクション情報を比較する。名前(name属性)が一致するものについては、保存済みセクションのkind属性を最新のセクションにコピーする。
		if (savedItem != null) {
			for (section_l in latestSection) {
				for (section_s in savedItem.sections) {
					if (section_l.name == section_s.name) { section_l.kind = section_s.kind; }
				}
			}
		}
		
		// ビュアーの初期化に必要な全てのセクション名とkind属性のとり得る値を生成する。
		var names:Array<String> = latestSection.map(function (section) { return section.name; } );
		var kinds:Array<String> = new Array<String>();
		{ // initialize kinds
			var constructors = SectionKind.getConstructors();
			constructors.iter(function (constructor) {
				if (constructor != SectionKind.Default.getName()) { kinds.push(constructor); }
			});
		}
		
		// ビュアーを生成する。
		canvasHeader.updateLabel(timelineName);
		
		var animation:Bool = if (savedItem != null) savedItem.animation else false;
		canvasContent.update(animation, latestSection, names, kinds);
		
	}
	
	/**
	 * ビュアーが変更されたとき呼び出される。
	 * セクション情報を生成し、これをタイムラインに保存する。
	 * @param	event
	 */
	private function changed(event:Event):Void {
		connector.send(ScriptApi.Save( canvasContent.toFlatomoItem() ));
	}
	
}

class Header extends Sprite {
	
	private var label:Label;
	private var button:PushButton;
	
	public function new(update:Event -> Void) {
		super();
		updateLabel("Flatomo");
		button = new PushButton(this, 0, 5, "UPDATE", update);
		resize(null);
		
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	
	private function resize(?e:Event = null):Void {
		var stageWidth = Lib.current.stage.stageWidth;
		graphics.clear();
		graphics.beginFill(0x454545, 1);
		graphics.drawRect(0, 0, stageWidth, 30);
		graphics.endFill();
		
		button.x = stageWidth - 120;
	}
	
	public function updateLabel(name:String):Void {
		if (label != null && contains(label)) {
			removeChild(label);
		}
		Style.LABEL_TEXT = 0xFFFFFF;
		label = new Label(this, 5, 5, name);
		Style.LABEL_TEXT = 0x666666;
	}
	
}
