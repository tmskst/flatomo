package flatomo.extension;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flatomo.FlatomoItem;
import flatomo.Section;
import flatomo.SectionKind;
import haxe.Unserializer;

using Lambda;

class ExtensionPanel extends Sprite implements IHandler {
	
	public static function main() {
		Lib.current.stage.addChild(new ExtensionPanel());
	}
	
	private var connector:Connector;
	private var viewers:Array<SectionViewer>;
	
	public function new() {
		super();
		this.connector = new Connector("flatomo.jsfl", "flatomo.extension.Script", this);
		this.scrollRect = new Rectangle(0, 0, Lib.current.stage.stageWidth, 200);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
	}
	
	private function mouseWheel(event:MouseEvent):Void {
		var rectangle:Rectangle = this.scrollRect;
		rectangle.y -= event.delta * 7;
		this.scrollRect = rectangle;
	}
	
	// ------------------------------------------------------------------------------------
	
	public function handle(raw_data:String):Void {
		var data:PanelApi = Unserializer.run(raw_data);
		switch (data) {
			case PanelApi.Refresh(latestSection) :
				// refresh(latestSection);
			case PanelApi.TimlineSelected(latestSection, savedItem) :
				timlineSelected(latestSection, savedItem);
			case PanelApi.DisabledTimlineSelected :
				// disabledTimlineSelected();
		}
	}
	
	private function timlineSelected(latestSection:Array<Section>, savedItem:Null<FlatomoItem>):Void {
		// セクションビュアーをすべて消去
		this.removeChildren();
		
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
		this.viewers = new Array<SectionViewer>();
		for (index in 0...latestSection.length) {
			var section:Section = latestSection[index];
			var viewer:SectionViewer = new SectionViewer(this, 5, 30 + 35 * index, section, names, kinds);
			viewer.addEventListener(SectionViewer.CHANGED, changed);
			viewers.push(viewer);
		}
		
	}
	
	/**
	 * ビュアーが変更されたとき呼び出される。
	 * セクション情報を生成し、これをタイムラインに保存する。
	 * @param	event
	 */
	private function changed(event:Event):Void {
		var sections:Array<Section> = new Array<Section>();
		for (index in 0...viewers.length) {
			var viewer:SectionViewer = viewers[index];
			sections.push(viewer.fetchLatestSection());
		}
		connector.send(ScriptApi.Save( { sections: sections, animation: false } ));
	}
	
}
