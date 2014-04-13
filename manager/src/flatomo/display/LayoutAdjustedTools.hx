package flatomo.display;

import starling.display.DisplayObject;

import flatomo.Layout;
import flatomo.RawTexture;

@:access(flatomo.display.ILayoutAdjusted)
class LayoutAdjustedTools {
	public static function update(source:ILayoutAdjusted, frame:Int):Void {
		if (source.visiblePropertyOverwrited && !source.visible) { return; }
		
		var layout = source.layouts.get(frame - 1);
		if (layout == null) { 
			source.visible = false;
			return;
		} else {
			source.visible = true;
		}
		
		if (source.layoutPropertiesOverwrited) {
			return;
		}

				source.visible = true;
				source.x = layout.x;
				source.y = layout.y;
				source.rotation = layout.rotation;
				source.scaleX = layout.scaleX;
				source.scaleY = layout.scaleY;
		
	}
}
