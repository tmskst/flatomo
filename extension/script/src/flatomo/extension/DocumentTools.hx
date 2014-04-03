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
		document.addDataToDocument(DOCUMENT_ATTR_FLATOMO, PersistentDataType.STRING, "flatomo");
	}
	
	/** 作業中のドキュメントに対しFlatomoを無効にします。 */
	private static function disableFlatomo(document:Document):Void {
		if (document.documentHasData(DOCUMENT_ATTR_FLATOMO)) {
			document.removeDataFromDocument(DOCUMENT_ATTR_FLATOMO);
		}
	}
	
}
