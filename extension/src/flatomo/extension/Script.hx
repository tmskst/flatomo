package flatomo.extension;
import flatomo.FlatomoItem;
import flatomo.FlatomoTools;
import flatomo.Section;
import haxe.Unserializer;

using Lambda;

class Script {
	
	public static function main() {
		send = Connector.send.bind("Panel");
		
		var flash:Flash = untyped fl;
		flash.addEventListener("timelineChanged", timelineChanged);
	}
	
	private static function timelineChanged():Void {
		var flash:Flash = untyped fl;
		var timeline:Timeline = flash.getDocumentDOM().getTimeline();
		if (timeline.libraryItem == null) { return; }
		
		var item:Item = null;
		{
			var index:Int = flash.getDocumentDOM().library.findItemIndex(timeline.libraryItem.name);
			item = flash.getDocumentDOM().library.items[index];
		}
		var sections_current:Array<Section> = FlatomoTools.fetchSections(timeline);
		var items_data:FlatomoItem = FlatomoTools.getItemData(item);
		
		var f_item:FlatomoItem = null;
		if (items_data != null) {
			sections_current.iter(function (section_c:Section) {
				items_data.sections.iter(function (section_i:Section) {
					if (section_c.name == section_i.name) {
						section_c.kind = section_i.kind;
					}
				});
			});
			f_item = { sections: sections_current, animation: items_data.animation };
		} else {
			f_item = { sections: sections_current, animation: false };
		}
		send(PanelApi.TimlineChanged(f_item));
	}
	
	private static function save(data:FlatomoItem):Void {
		var flash:Flash = untyped fl;
		var timeline:Timeline = flash.getDocumentDOM().getTimeline();
		var item:Item = null;
		{
			var index:Int = flash.getDocumentDOM().library.findItemIndex(timeline.libraryItem.name);
			item = flash.getDocumentDOM().library.items[index];
		}
		FlatomoTools.setItemData(item, data);
	}
	
	private static var send:Api -> Void;
	
	public static function handle(raw_data:String):Void {
		var data:ScriptApi = Unserializer.run(raw_data);
		switch (data) {
			case Save(data) : 
				save(data);
		}
	}
	
}
