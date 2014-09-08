package flatomo;

import js.JQuery;

class JQueryTools {
	/**
	 * 条件を満たすとき要素を有効にし条件を満たさないとき要素は無効になる
	 * @param	query 対象の要素
	 * @param	enabled 条件式
	 */
	public static function enable(query:JQuery, enabled:Bool):Void {
		if (enabled) {
			query.removeAttr('disabled');
		} else {
			query.attr('disabled', 'disabled');
		}
	}
}
