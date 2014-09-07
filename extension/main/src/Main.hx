package ;

import adobe.cep.CSInterface;
import haxe.Serializer;
import haxe.Unserializer;
import js.JQuery;

class Main {
	
	public static function main() {
		invoke(ScriptApi.ValidationTest, function(validDocument_raw:String) {
			var validDocument:Bool = Unserializer.run(validDocument_raw);
			if (validDocument) {
				new JQuery('div#warning').css('display', 'none');
			}
		});
	}
	
	/**
	 * JSFLを実行します
	 * @param	command
	 * @param	callback
	 */
	private static function invoke(command:ScriptApi, callback:Dynamic -> Void):Void {
		new CSInterface().evalScript('Script.invoke("' + Serializer.run(command) + '")', callback);
	}
	
}
