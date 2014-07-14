package flatomo;

import haxe.Resource;
import haxe.Template;
import jsfl.Document;
import jsfl.Lib;
import jsfl.Lib.fl;

using flatomo.extension.DocumentTools;

class PublishDialog {
	
	public static function main() {
		var document:Document = fl.getDocumentDOM();
		if (document == null) {
			return Lib.alert("有効なドキュメントを開いてください");
		}
		if (!document.isFlatomo()) {
			return Lib.alert("Flatomoが有効でないドキュメントです");
		}
		
		var publishDialogTemplate = new Template(Resource.getString("PublishDialog"));
		var result:Dynamic = fl.xmlPanelFromString(publishDialogTemplate.execute(
			{ // context
				dynamicPublish: false,
				staticPublish : false,
			}
		));
		
		// ダイアログがキャンセルされたら保存せずに終了
		if (result.dismiss == "cancel") { return; }
		
		var staticPublish:Bool	= result.staticPublish == "true";
		if (staticPublish) { Exporter.run(); }
		
		var dynamicPublish:Bool	= result.dynamicPublish == "true";
		if (dynamicPublish) { Publisher.run(); }
		
	}
}
