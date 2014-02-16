package flatomo.extension;

import flatomo.FlatomoTools;
import jsfl.Lib.fl;

using flatomo.extension.ItemTools;
using flatomo.extension.DocumentTools;

class DisableFlatomo {
	
	/**
	 * 作業中のドキュメントでFlatomoを無効にします。
	 * Flatomoに関する全ての設定は失われます。
	 */
	@:access(flatomo.FlatomoTools)
	@:access(flatomo.extension.ItemTools)
	@:access(flatomo.extension.DocumentTools)
	private static function main():Void {
		if (!fl.getDocumentDOM().isFlatomo()) { return; }
		
		for (item in fl.getDocumentDOM().library.items) {
			item.removeFlatomoItem();
		}
		FlatomoTools.deleteAllElementPersistentData();
		fl.getDocumentDOM().disableFlatomo();
	}
	
}
