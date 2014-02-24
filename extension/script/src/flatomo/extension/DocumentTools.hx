package flatomo.extension;

import jsfl.Document;
import jsfl.PersistentDataType;

class DocumentTools {
	
	public static inline var DOCUMENT_ATTR_FLATOMO:String = "flatomo";
	
	/** 作業中のドキュメントでFlatomoが動作するかどうか */
	public static function isFlatomo(document:Document):Bool {
		return document.documentHasData(DOCUMENT_ATTR_FLATOMO);
	}
	
	/** 作業中のドキュメントに対しFlatomoを有効にします。 */
	private static function enableFlatomo(document:Document):Void {
		var path = jsfl.Lib.prompt("設定シンボルのFQCN", "com.example.Config");
		if (path == null) { return; }
		document.addDataToDocument(DOCUMENT_ATTR_FLATOMO, PersistentDataType.STRING, path);
	}
	
	/** 作業中のドキュメントに対しFlatomoを無効にします。 */
	private static function disableFlatomo(document:Document):Void {
		document.removeDataFromDocument(DOCUMENT_ATTR_FLATOMO);
	}
	
	public static function fetchConfigSymbolClassPath(document:Document):String {
		return document.getDataFromDocument(DOCUMENT_ATTR_FLATOMO);
	}
}
