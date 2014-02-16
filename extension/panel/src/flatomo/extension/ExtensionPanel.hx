package flatomo.extension;
import com.bit101.components.CheckBox;
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.Style;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flatomo.extension.ExtensionPanel.Header;
import flatomo.FlatomoItem;
import flatomo.Section;
import flatomo.SectionKind;
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
	private var canvasContent:Sprite;
	
	private var canvasAnimationViewer:Sprite;
	private var animationViewer:CheckBox;
	
	private var canvasSectionViewer:Sprite;
	private var sectionViewers:Array<SectionViewer>;
	
	public function new() {
		super();
		
		Style.embedFonts = false;
		Style.fontSize = 12;
		
		this.connector = new Connector("flatomo.jsfl", "flatomo.extension.Script", this);
		this.scrollRect = new Rectangle(0, 0, Lib.current.stage.stageWidth, 200);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		
		canvasContent = new Sprite();
		canvasContent.scrollRect = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		canvasContent.y = 30;
		this.addChild(canvasContent);
		
		canvasHeader = new Header(function (event:Event):Void {
			connector.send(ScriptApi.Refresh);
		});
		this.addChild(canvasHeader);
		
		canvasSectionViewer = new Sprite();
		canvasContent.addChild(canvasSectionViewer);
		
		canvasAnimationViewer = new Sprite();
		canvasContent.addChild(canvasAnimationViewer);
	}
	
	private function mouseWheel(event:MouseEvent):Void {
		var rectangle:Rectangle = canvasContent.scrollRect;
		rectangle.y -= event.delta * 7;
		canvasContent.scrollRect = rectangle;
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
		// セクションビュアーをすべて消去
		canvasSectionViewer.removeChildren();
		canvasAnimationViewer.removeChildren();
		
		new Label(canvasSectionViewer, 10, 20, "Disabled Timline");
	}
	
	/**
	 * 作業中のドキュメントはFlatomoに対応していないか有効でない
	 */
	private function flatomoDisabled():Void {
		// セクションビュアーをすべて消去
		canvasSectionViewer.removeChildren();
		canvasAnimationViewer.removeChildren();
		
		new Label(canvasSectionViewer, 10, 20, "Flatomo is disabled");
	}
	
	private function timlineSelected(timelineName:String, latestSection:Array<Section>, savedItem:Null<FlatomoItem>):Void {
		// セクションビュアーをすべて消去
		canvasSectionViewer.removeChildren();
		canvasAnimationViewer.removeChildren();
		canvasContent.scrollRect = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		
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
		animationViewer = new CheckBox(canvasAnimationViewer, 5, 10, "Animation", changed);
		animationViewer.selected = if (savedItem != null) savedItem.animation else false;
		
		this.sectionViewers = new Array<SectionViewer>();
		for (index in 0...latestSection.length) {
			var section:Section = latestSection[index];
			var viewer:SectionViewer = new SectionViewer(canvasSectionViewer, 5, 30 + 35 * index, section, names, kinds);
			viewer.addEventListener(SectionViewer.CHANGED, changed);
			sectionViewers.push(viewer);
		}
		
	}
	
	/**
	 * ビュアーが変更されたとき呼び出される。
	 * セクション情報を生成し、これをタイムラインに保存する。
	 * @param	event
	 */
	private function changed(event:Event):Void {
		var sections:Array<Section> = new Array<Section>();
		for (index in 0...sectionViewers.length) {
			var viewer:SectionViewer = sectionViewers[index];
			sections.push(viewer.fetchLatestSection());
		}
		connector.send(ScriptApi.Save( { sections: sections, animation: animationViewer.selected } ));
	}
	
}

class Header extends Sprite {
	
	private var label:Label;
	
	public function new(update:Event -> Void) {
		super();
		graphics.beginFill(0x000000, 0.8);
		graphics.drawRect(0, 0, Lib.current.stage.stageWidth, 30);
		graphics.endFill();
		
		updateLabel("Flatomo");
		new PushButton(this, Lib.current.stage.stageWidth - 120, 5, "UPDATE", update);
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
