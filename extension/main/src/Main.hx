package ;

import adobe.cep.CSInterface;
import flatomo.ExtensionItem;
import flatomo.ExtensionLibrary;
import haxe.Serializer;
import haxe.Unserializer;
import js.JQuery;
import js.JQuery.JqEvent;

class Main {
	
	public static function main() { new Main(); }
	
	private function new() {
		invoke(ScriptApi.ValidationTest, function(validDocument_raw:Serialization) {
			var validDocument:Bool = Unserializer.run(validDocument_raw);
			if (validDocument) { initialize(); }
		});
	}
	
	private function initialize():Void {
		new JQuery('div#warning').css('display', 'none');
		invoke(ScriptApi.GetExtensionLibrary, function(library_raw:Serialization) {
			createLibraryDiv(Unserializer.run(library_raw));
		});
	}
	
	private function createLibraryDiv(extensionLibrary:ExtensionLibrary):Void {
		var library = new JQuery('div#library');
		
		// 'div#library div'を削除
		library.children("div").remove();
		
		// ライブラリを作成
		for (item in extensionLibrary) {
			var element = new JQuery('<div>$item</div>');
			element.click(function (event:JqEvent) {
				var itemPath:String = new JQuery(event.currentTarget).text();
				invoke(ScriptApi.GetExtensionItem(itemPath), function (extensionItem_raw:Serialization) {
					var extensionItem:ExtensionItem = Unserializer.run(extensionItem_raw);
					trace(extensionItem);
				});
			});
			library.append(element);
		}
	}
	
	/**
	 * JSFLを実行します
	 * @param	command
	 * @param	callback
	 */
	private function invoke(command:ScriptApi, callback:Dynamic -> Void):Void {
		new CSInterface().evalScript('Script.invoke("' + Serializer.run(command) + '")', callback);
	}
	
}
