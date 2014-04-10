package flatomo.display;

import starling.display.DisplayObject;

class LayoutAdjustedTools {
	public static function update(source:ILayoutAdjusted, frame:Int):Void {
		if (!source.locked) {
			var layout = source.layouts.get(frame - 1);
			if (layout != null) {
				var object:DisplayObject = cast source;
				object.visible = true;
				object.x = layout.x;
				object.y = layout.y;
				object.rotation = layout.rotation;
				object.scaleX = layout.scaleX;
				object.scaleY = layout.scaleY;
			}
		}
	}
}
