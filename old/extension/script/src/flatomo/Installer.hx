package flatomo;

import jsfl.FLfile;
import jsfl.Lib;
import jsfl.Lib.fl;

class Installer {
	
	public static function main() {
		var confirm =  Lib.confirm("インストールします");
		if (!confirm) {
			fl.trace("インストールを中断しました");
			return;
		}
		
		var scriptURI = fl.scriptURI.substr(0, fl.scriptURI.lastIndexOf("/script/bin") + 1);
		var configURI = fl.configURI;
		
		// Panel
		copy(scriptURI + "script/bin/PublishDialog.jsfl", configURI + "WindowSWF/PublishDialog.jsfl");
		copy(scriptURI + "script/bin/DocumentConfig.jsfl", configURI + "WindowSWF/DocumentConfig.jsfl");
		copy(scriptURI + "script/bin/FlatomoItemConfig.jsfl", configURI + "WindowSWF/FlatomoItemConfig.jsfl");
		copy(scriptURI + "panel/bin/Flatomo.swf", configURI + "WindowSWF/Flatomo.swf");
	}
	
	private static function copy(fileURI:String, copyURI:String):Void {
		if (!FLfile.exists(fileURI)) {
			Lib.throwError('ファイル${fileURI}が見つかりません');
		}
		if (FLfile.exists(copyURI)) {
			FLfile.remove(copyURI);
			fl.trace('${copyURI}を削除しました');
		}
		fl.trace('${fileURI}を${copyURI}にコピーしました');
		FLfile.copy(fileURI, copyURI);
	}
	
}
