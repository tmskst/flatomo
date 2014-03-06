package flatomo.extension;

import flatomo.FlatomoTools;
import haxe.Serializer;
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
		
		var obj = FlatomoTools.createLibrary(document.library);
		fl.trace(Serializer.run(obj));
		
		id = fl.addEventListener(EventType.POST_PUBLISH, postPublish);
		document.publish();
	}
	
	@:access(flatomo.FlatomoTools)
	private static function postPublish():Void {
		FlatomoTools.clean(fl.getDocumentDOM().library);
		fl.removeEventListener(EventType.POST_PUBLISH, id);
	}
}
