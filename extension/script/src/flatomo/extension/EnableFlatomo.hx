package flatomo.extension;

import jsfl.Lib.fl;

using flatomo.extension.DocumentTools;

class EnableFlatomo {
	
	/** 作業中のドキュメントでFlatomoが使えるようにドキュメントを変更します。 */
	@:access(flatomo.extension.DocumentTools)
	public static function main() {
		var document = fl.getDocumentDOM();
		if (document != null) {
			document.enableFlatomo();
		}
	}
	
}
