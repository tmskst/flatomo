package ;

import flash.display.BitmapData;
import flash.geom.Rectangle;

typedef RawTexture = {
	var name:String;
	var index:Int;
	var image:BitmapData;
	var frame:Rectangle;
	var unionBounds:Rectangle;
}
