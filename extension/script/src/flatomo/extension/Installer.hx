package flatomo.extension;

import jsfl.FLfile;
import jsfl.Lib;
import jsfl.Lib.fl in fl;

class Installer {
	
	public static function main() {
		
		var confirm =  Lib.confirm("インストールします");
		if (!confirm) {
			fl.trace("インストールを中断しました");
			return;
		}
		
		var scriptURI = fl.scriptURI.substr(0, fl.scriptURI.lastIndexOf("/script/bin") + 1);
		var configURI = fl.configURI;
		
		// Scripts
		copy(scriptURI + "script/bin/EnableFlatomo.jsfl", configURI + "Commands/Flatomoを有効にする.jsfl");
		copy(scriptURI + "script/bin/DisableFlatomo.jsfl", configURI + "Commands/Flatomoを無効にする.jsfl");
		copy(scriptURI + "script/bin/Publisher.jsfl", configURI + "Commands/Flatomo向けにパブリッシュ.jsfl");
		
		// Panel
		copy(scriptURI + "script/bin/flatomo.jsfl", configURI + "WindowSWF/flatomo.jsfl");
		copy(scriptURI + "panel/bin/Panel.swf", configURI + "WindowSWF/Panel.swf");
	}
	
	private static function copy(fileURI:String, copyURI:String):Void {
		if (!FLfile.exists(fileURI)) {
			Lib.throwError('ファイル${fileURI}が見つかりません');
		}
		fl.trace('${fileURI}を${copyURI}にコピーしました');
		FLfile.copy(fileURI, copyURI);
	}
	
}
