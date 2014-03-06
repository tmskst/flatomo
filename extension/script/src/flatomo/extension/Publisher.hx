package flatomo.extension;

import flatomo.FlatomoTools;
import haxe.Serializer;
import jsfl.Document;
import jsfl.EventType;
import jsfl.FLfile;
import jsfl.Lib.fl;

using flatomo.extension.DocumentTools;

class Publisher {
	
	private static var id:Int;
	
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (!document.isFlatomo()) { return; }
		writeLibrary();
		
		id = fl.addEventListener(EventType.POST_PUBLISH, postPublish);
		document.publish();
	}
	
	@:access(flatomo.FlatomoTools)
	private static function writeLibrary():Void {
		var document:Document = fl.getDocumentDOM();
		var library = FlatomoTools.createLibrary(document.library);
		var swfPath:String = document.getSWFPathFromProfile();
		var fileUri = swfPath.substring(0, swfPath.lastIndexOf(".")) + "." + "flatomo";
		FLfile.write(fileUri, Serializer.run(library));
	}
	
	@:access(flatomo.FlatomoTools)
	private static function postPublish():Void {
		FlatomoTools.clean(fl.getDocumentDOM().library);
		fl.removeEventListener(EventType.POST_PUBLISH, id);
	}
	
}
