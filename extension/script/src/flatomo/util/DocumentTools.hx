package flatomo.util;

import flatomo.DocumentStatus;
import flatomo.PublishProfile;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Document;
import jsfl.PersistentDataType;

class DocumentTools {
	
	private static inline var FLATOMO_ENABLED:String = "FLATOMO_ENABLED";
	private static inline var FLATOMO_PUBLISH_PROFILE:String = "FLATOMO_PUBLISH_PROFILE";
	
	/** 作業中のドキュメントでFlatomoが動作するかどうか */
	public static function isFlatomo(document:Document):Bool {
		return document.documentHasData(FLATOMO_ENABLED);
	}
	
	/** 作業中のドキュメントに対しFlatomoを有効にします */
	public static function enableFlatomo(document:Document):Void {
		document.addDataToDocument(FLATOMO_ENABLED, PersistentDataType.STRING, "F");
	}
	
	/** 作業中のドキュメントに対しFlatomoを無効にします */
	public static function disableFlatomo(document:Document):Void {
		if (document.documentHasData(FLATOMO_ENABLED)) {
			document.removeDataFromDocument(FLATOMO_ENABLED);
		}
	}
	
	/** パブリッシュプロファイルを作業中のドキュメントに保存します */
	public static function setPublishProfile(document:Document, publishProfile:PublishProfile):Void {
		if (isFlatomo(document)) {
			if (document.documentHasData(FLATOMO_PUBLISH_PROFILE)) {
				document.removeDataFromDocument(FLATOMO_PUBLISH_PROFILE);
			}
			document.addDataToDocument(FLATOMO_PUBLISH_PROFILE, PersistentDataType.STRING, Serializer.run(publishProfile));
		}
	}
	
	/** 作業中のドキュメントの状態を取得します */
	public static function validationTest(document:Document):DocumentStatus {
		return if (document == null) Invalid else if (isFlatomo(document)) Enabled else Disabled;
	}
	
	/** 作業中のドキュメントからパブリッシュプロファイルを取得します */
	public static function getPublishProfile(document:Document):PublishProfile {
		return Unserializer.run(document.getDataFromDocument(FLATOMO_PUBLISH_PROFILE));
	}
	
}
