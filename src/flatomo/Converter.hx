package flatomo;
import flash.geom.Rectangle;

class Converter {
	
	public static function createTextField(source:flash.text.TextField):starling.text.TextField {
		var bounds:Rectangle = source.getBounds(source);
		var width:Int = Std.int(bounds.width);
		var height:Int = Std.int(bounds.height);
		return new starling.text.TextField(width, height, source.text);
	}
	
	public static function createButton(source:flash.display.SimpleButton):starling.display.Button {
		var upState = starling.textures.Texture.fromBitmapData(Blitter.toBitmapData(source.upState));
		var downState = starling.textures.Texture.fromBitmapData(Blitter.toBitmapData(source.downState));
		return new starling.display.Button(upState, "", downState);
	}
	
	public static function copy(source:flash.display.DisplayObject, object:starling.display.DisplayObject):starling.display.DisplayObject {
		object.transformationMatrix = source.transform.matrix;
		for (f_filter in source.filters) {
			var s_filter = convertFilter(f_filter);
			if (s_filter != null) {
				object.filter = s_filter;
				break;
			}
		}
		object.blendMode = convertBlendMode(source.blendMode);
		
		return object;
	}
	
	private static function convertBlendMode(blendMode:flash.display.BlendMode) {
		return switch (blendMode) {
			case flash.display.BlendMode.ADD	: starling.display.BlendMode.ADD;
			case flash.display.BlendMode.ERASE	: starling.display.BlendMode.ERASE;
			case flash.display.BlendMode.MULTIPLY : starling.display.BlendMode.MULTIPLY;
			case flash.display.BlendMode.SCREEN	: starling.display.BlendMode.SCREEN;
			case flash.display.BlendMode.NORMAL	: starling.display.BlendMode.AUTO;
			default : starling.display.BlendMode.AUTO;
		}
	}
	
	private static function convertFilter(filter:flash.filters.BitmapFilter):starling.filters.FragmentFilter {
		if (Std.is(filter, flash.filters.BlurFilter)) {
			return blurFilter(cast(filter, flash.filters.BlurFilter));
		}
		if (Std.is(filter, flash.filters.DropShadowFilter)) {
			return dropShadowFilter(cast(filter, flash.filters.DropShadowFilter));
		}
		if (Std.is(filter, flash.filters.GlowFilter)) {
			return glowFilter(cast(filter, flash.filters.GlowFilter));
		}
		if (Std.is(filter, flash.filters.DisplacementMapFilter)) {
			return displacementMapFilter(cast(filter, flash.filters.DisplacementMapFilter));
		}
		return null;
	}
	
	/* Filters */
	
	private static function blurFilter(source:flash.filters.BlurFilter) {
		return new starling.filters.BlurFilter(
			source.blurX, source.blurY, source.quality
		);
	}
	
	private static function dropShadowFilter(source:flash.filters.DropShadowFilter) {
		return starling.filters.BlurFilter.createDropShadow(
			source.distance, source.angle, source.color, source.alpha, source.blurX, source.quality
		);
	}
	
	private static function glowFilter(source:flash.filters.GlowFilter) {
		return starling.filters.BlurFilter.createGlow(
			source.color, source.alpha, source.blurX, source.quality
		);
	}
	
	private static function displacementMapFilter(source:flash.filters.DisplacementMapFilter) {
		return new starling.filters.DisplacementMapFilter(
			starling.textures.Texture.fromBitmapData(source.mapBitmap),
			source.mapPoint, source.componentX, source.componentY, source.scaleX, source.scaleY
		);
	}
	
}