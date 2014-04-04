package flatomo.extension;

import jsfl.Document;
import jsfl.Lib.fl;

using flatomo.extension.ItemTools;
using flatomo.extension.DocumentTools;

class DisableFlatomo {
	
	/**
	 * 作業中のドキュメントでFlatomoを無効にします。
	 * Flatomoに関する全ての設定は失われます。
	 */
	@:access(flatomo.extension.ItemTools)
	@:access(flatomo.extension.DocumentTools)
	private static function main():Void {
		var document:Document = fl.getDocumentDOM();
		if (document == null || !document.isFlatomo()) { return; }
		
		for (item in document.library.items) {
			item.removeFlatomoItem();
		}
		document.disableFlatomo();
	}
	
}
