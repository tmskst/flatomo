package flatomo.extension;

import flatomo.FlatomoTools;
import jsfl.Document;
import jsfl.EventType;
import jsfl.Lib.fl;

using flatomo.extension.DocumentTools;

class Publisher {
	
	private static var id:Int;
	
	@:access(flatomo.FlatomoTools)
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (!document.isFlatomo()) { return; }
		
		FlatomoTools.setAllElementPersistentData(document.library);
		FlatomoTools.createConfigSymbol();
		FlatomoTools.setLibrary(FlatomoTools.createLibrary(document.library));
		
		id = fl.addEventListener(EventType.POST_PUBLISH, postPublish);
		document.publish();
	}
	
	@:access(flatomo.FlatomoTools)
	private static function postPublish():Void {
		FlatomoTools.deleteConfigSymbol();
		fl.removeEventListener(EventType.POST_PUBLISH, id);
	}
	
}
