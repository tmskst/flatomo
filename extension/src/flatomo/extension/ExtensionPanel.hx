package flatomo.extension;
import com.bit101.components.ComboBox;
import com.bit101.components.Label;
import com.bit101.components.Panel;
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
	
	public function new() {
		super();
		this.connector = new Connector("flatomo.jsfl", "flatomo.extension.Script", this);
		this.scrollRect = new Rectangle(0, 0, Lib.current.stage.stageWidth, 200);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
	}
	
	private var item:FlatomoItem;
	
	private function reload(item:FlatomoItem/*, items_data:FlatomoItem*/):Void {
		/*
		var unchanged_sections:Array<Section> = null;
		if (items_data != null) {
			var sections_current = item.sections;
			unchanged_sections = sections_current.filter(function (section:Section):Bool {
				return items_data.sections.exists(function (items_section:Section):Bool {
					return (Serializer.run(section) == Serializer.run(items_section));
				});
			});
		}
		*/
		
		this.item = item;
		var sections:Array<Section> = item.sections;
		var sectionNames = sections.map(function (section) { return section.name; } );
		var sectionKinds = new Array<String>();
		{ // INITIALIZE
			var kinds = SectionKind.getConstructors();
			kinds.iter(function (kind) {
				if (kind != SectionKind.Default.getName()) { sectionKinds.push(kind); }
			});
		}
		
		for (index in 0...sections.length) {
			var section:Section = sections[index];
			/*
			if (unchanged_sections != null) {
				if (!unchanged_sections.exists(function (elt) { return elt.name == section.name; })) {
					new Label(this, 5, 30 + 30 * index, "X");
				}
			}
			*/
			var panel = new Panel(this, 5, 30 + 35 * index);
			panel.name = '${index}_PANEL';
			panel.width = 330;
			panel.height = 30;
			
			var label = new Label(panel, 5, 5, section.name);
			
			var kind = new ComboBox(panel, 120, 5, "ERROR", sectionKinds);
			kind.name = '${index}_SECTION_KIND';
			kind.selectedItem = section.kind.getName();
			kind.addEventListener(Event.SELECT, kindChanged);
			
			var goto = new ComboBox(panel, 225, 5,  "ERROR", sectionNames);
			goto.name = '${index}_GOTO';
			goto.selectedIndex = 0;
			goto.visible = switch (section.kind) {
				case SectionKind.Goto(_) : true;
				case _ : false;
			}
		}
		
	}
	
	private function save():Void {
		for (index in 0...item.sections.length) {
			var section:Section = item.sections[index];
			var kind:SectionKind = null;
			{
				var panel:Panel = cast(this.getChildByName('${index}_PANEL'), Panel);
				var kind_raw:String = cast(panel.content.getChildByName('${index}_SECTION_KIND'), ComboBox).selectedItem;
				var goto_raw:String = cast(panel.content.getChildByName('${index}_GOTO'), ComboBox).selectedItem;
				
				if (kind_raw == "Goto") {
					var r:Section = item.sections.filter(function (target) {
						return (target.name == goto_raw);
					})[0];
					kind = SectionKind.Goto(r.begin);
				} else {
					kind = SectionKind.createByName(kind_raw);
				}
			}
			section.kind = kind;
		}
	}
	
	private function kindChanged(event:Event):Void {
		var id:Int = Std.parseInt(event.currentTarget.name);
		var source:String = cast(event.currentTarget, ComboBox).selectedItem;
		var panel:Panel = cast(this.getChildByName('${id}_PANEL'), Panel);
		panel.content.getChildByName('${id}_GOTO').visible = (source == "Goto");
		
		save();
		connector.send(ScriptApi.Save(item));
	}
	
	private function onScroll(event:MouseEvent):Void {
		var rectangle:Rectangle = this.scrollRect;
		rectangle.y -= event.delta * 7;
		this.scrollRect = rectangle;
	}
	
	public function handle(raw_data:String):Void {
		var data:PanelApi = Unserializer.run(raw_data);
		switch (data) {
			case PanelApi.TimlineChanged(item) :
				removeChildren();
				reload(item);
		}
	}
	
}
