package flatomo.util;

import jsfl.Document;
import jsfl.PersistentDataType;

class DocumentTools {
	
	public static inline var NAMESPACE_FLATOMO:String = "flatomo";
	
	/** 作業中のドキュメントでFlatomoが動作するかどうか */
	public static function isFlatomo(document:Document):Bool {
		return document.documentHasData(NAMESPACE_FLATOMO);
	}
	
	/** 作業中のドキュメントに対しFlatomoを有効にします */
	public static function enableFlatomo(document:Document):Void {
		document.addDataToDocument(NAMESPACE_FLATOMO, PersistentDataType.STRING, "F");
	}
	
	/** 作業中のドキュメントに対しFlatomoを無効にします */
	public static function disableFlatomo(document:Document):Void {
		if (document.documentHasData(NAMESPACE_FLATOMO)) {
			document.removeDataFromDocument(NAMESPACE_FLATOMO);
		}
	}
	
}
