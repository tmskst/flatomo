package flatomo;

import haxe.Resource;
import haxe.Template;
import jsfl.Document;
import jsfl.Lib;
import jsfl.Lib.fl;

using flatomo.extension.util.ItemTools;
using flatomo.extension.util.DocumentTools;

class DocumentConfig {
	
	@:access(flatomo.extension.util.ItemTools)
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (document == null) {
			return Lib.alert("有効なドキュメントを開いてください");
		}
		
		var documentConfigTemplate = new Template(Resource.getString("DocumentConfig"));
		var result:Dynamic = fl.xmlPanelFromString(documentConfigTemplate.execute(
			{ // context
				isFlatomoDocument: document.isFlatomo(),
			}
		));
		
		// ダイアログがキャンセルされたら保存せずに終了
		if (result.dismiss == "cancel") { return; }
		
		// ドキュメントの情報を更新
		var latestFlatomoDocument:Bool = result.isFlatomoDocument == "true";
		switch (latestFlatomoDocument) {
			case true :
				document.enableFlatomo();
			case false :
				for (item in document.library.items) {
					item.removeFlatomoItem();
				}
				document.disableFlatomo();
		}
	}
}
