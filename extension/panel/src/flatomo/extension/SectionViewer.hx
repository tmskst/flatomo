package flatomo.extension;
import com.bit101.components.ComboBox;
import com.bit101.components.Label;
import com.bit101.components.Panel;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flatomo.Section;
import flatomo.SectionKind;

class SectionViewer extends Panel {
	
	public static var CHANGED:String = "SectionViewer:CHANGED";
	public var section(default, null):Section;
	
	private var kind:ComboBox;
	private var goto:ComboBox;
	
	public function new(parent:DisplayObjectContainer, xpos:Float, ypos:Float, section:Section, names:Array<String>, kinds:Array<String>) {
		super(parent, xpos, ypos);
		this.width = 330;
		this.height = 30;
		this.section = section;
		
		new Label(this, 5, 5, section.name);
		this.kind = new ComboBox(this, 120, 5, "ERROR", kinds);
		{ // initialize kind
			kind.selectedItem = switch (section.kind) {
				case SectionKind.Default : SectionKind.Pass.getName();
				case v : v.getName();
			}
			kind.addEventListener(Event.SELECT, changed);
		}
		this.goto = new ComboBox(this, 225, 5,  "ERROR", names);
		{ // initialize goto
			goto.selectedIndex = 0;
			goto.addEventListener(Event.SELECT, changed);
			goto.visible = switch (section.kind) {
				case SectionKind.Goto(_) : true;
				case _ : false;
			}
		}
		
	}
	
	private function changed(event:Event):Void {
		var kind_raw:String = this.kind.selectedItem;
		goto.visible = (kind_raw == "Goto");
		
		this.dispatchEvent(new Event(CHANGED));
	}
	
	public function fetchLatestSection():Section {
		var sectionKind:SectionKind = null;
		{ // initialize sectionKind
			var kind_raw:String = this.kind.selectedItem;
			if (kind_raw == "Goto") {
				var goto_raw:String = this.goto.selectedItem;
				sectionKind = SectionKind.Goto(goto_raw);
			} else {
				sectionKind = SectionKind.createByName(kind_raw);
			}
		}
		this.section.kind = sectionKind;
		return this.section;
	}
	
}
