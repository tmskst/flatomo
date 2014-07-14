package flatomo;

import haxe.Resource;
import jsfl.Lib.fl;

class DocumentConfig {
	public static function main() {
		fl.xmlPanelFromString(Resource.getString("DocumentConfig"));
	}
}
