package flatomo.extension;
import flatomo.FlatomoItem;
import flatomo.Section;
import haxe.Unserializer;
import jsfl.EventType;
import jsfl.Flash;
import jsfl.Item;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.Timeline;


using flatomo.extension.DocumentTools;
using flatomo.extension.ItemTools;

using Lambda;

class Script {
	
	private static var send:Api -> Void;
	
	public static function main() {
		send = Connector.send;
		
		var flash:Flash = untyped fl;
		flash.addEventListener(EventType.TIMELINE_CHANGED, refresh);
	}
	
	/**
	 * 作業タイムラインが変更されたときに呼び出される。
	 * パネルに作業タイムラインが変更されたこと（PanelApi.TimlineSelected, PanelApi.DisabledTimlineSelected）を通知する。
	 */
	private static function timelineChanged():Void {
		var flash:Flash = untyped fl;
		var timeline:Timeline = flash.getDocumentDOM().getTimeline();
		
		// 作業タイムラインがライブラリ内に存在しない場合はFlatomoItemを保存することができない
		if (timeline.libraryItem == null) {
			send(PanelApi.DisabledTimlineSelected);
			return;
		}
		
		var item:Item = null;
		{ // initialize item
			var library:Library = flash.getDocumentDOM().library;
			var index:Int = library.findItemIndex(timeline.libraryItem.name);
			item = library.items[index];
		}
		
		var latestSection:Array<Section> = SectionCreator.fetchSections(timeline);
		var savedItem:FlatomoItem = item.getFlatomoItem();
		
		send(PanelApi.TimlineSelected(latestSection, savedItem));
	}
	
	// ------------------------------------------------------------------------------------
	
	public static function handle(raw_data:String):Void {
		var data:ScriptApi = Unserializer.run(raw_data);
		switch (data) {
			case ScriptApi.Refresh :
				refresh();
			case ScriptApi.Save(data) :
				save(data);
		}
	}
	
	/**
	 * 作業タイムラインにFlatomoItemを保存します。
	 * @param	data 保存するデータ
	 */
	@:access(flatomo.extension.ItemTools)
	private static function save(data:FlatomoItem):Void {
		var flash:Flash = untyped fl;
		if (!flash.getDocumentDOM().isFlatomo()) {
			return;
		}
		
		var timeline:Timeline = flash.getDocumentDOM().getTimeline();
		var item:Item = null;
		{ // initialize item
			var library:Library = flash.getDocumentDOM().library;
			var index:Int = library.findItemIndex(timeline.libraryItem.name);
			item = library.items[index];
		}
		item.setFlatomoItem(data);
	}
	
	/**
	 * 現在（最新）のタイムラインを元にセクション情報を生成しパネルに送信します。
	 */
	private static function refresh():Void {
		if (!fl.getDocumentDOM().isFlatomo()) {
			send(PanelApi.FlatomoDisabled);
		} else {
			timelineChanged();
		}
	}
	
}
