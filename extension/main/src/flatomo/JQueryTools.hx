package flatomo;

import js.JQuery;

class JQueryTools {
	public static function enable(query:JQuery, enabled:Bool):Void {
		if (enabled) {
			query.removeAttr('disabled');
		} else {
			query.attr('disabled', 'disabled');
		}
	}
}
