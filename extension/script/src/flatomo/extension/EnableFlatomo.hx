package flatomo.extension;

import flatomo.FlatomoTools;
import jsfl.Lib.fl;

using flatomo.extension.ItemTools;
using flatomo.extension.DocumentTools;

class EnableFlatomo {
	
	/**
	 * 作業中のドキュメントでFlatomoが使えるようにドキュメントを変更します。
	 */
	@:access(flatomo.extension.DocumentTools)
	public static function main() {
		fl.getDocumentDOM().enableFlatomo();
	}
	
}
