package flatomo;

import haxe.Resource;
import jsfl.Lib.fl;

class PublishDialog {
	public static function main() {
		fl.xmlPanelFromString(Resource.getString("PublishDialog"));
	}
}
