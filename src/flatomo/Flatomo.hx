package flatomo;

import flash.display.SimpleButton;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;
import starling.core.Starling;
import starling.display.Button;
import starling.display.Image;
import starling.text.TextField;
import starling.textures.Texture;

#if flashdevelop_hack
import BitmapData;
import DisplayObject;
import DisplayObjectContainer;
import Sprite;
import MovieClip;
import TextField;
#end

class Flatomo {
	
	public static function create(root:flash.display.DisplayObject):starling.display.DisplayObject {
		var flatomo = new Flatomo();
		flatomo.scan(root);
		return flatomo.current;
	}
	
	/* ---------------------- */
	
	private function new() {
		this.current = new starling.display.Sprite();
	}
	
	private var current:starling.display.Sprite;
	
	/* ---------------------- */
	
	private function scan(object:flash.display.DisplayObject):Void {
		if (isAnimation(object)) {
			var movie = cast(object, flash.display.MovieClip);
			parseAnimation(movie);
		}
		else if (isTexture(object)) {
			parseTexture(object);
		}
		else {
			// Textureでないオブジェクトは全てDisplayObjectContainerです
			scanChildren(cast(object, flash.display.DisplayObjectContainer));
		}
	}
	
	private function scanChildren(parent:flash.display.DisplayObjectContainer):Void {
		for (i in 0...parent.numChildren) {
			scan(parent.getChildAt(i));
		}
	}
	
	private function parseTexture(source:flash.display.DisplayObject):Void {
		var object:starling.display.DisplayObject;
		
		if (Std.is(source, flash.text.TextField)) {
			object = parseTextField(cast(source, flash.text.TextField));
		}
		else if (Std.is(source, SimpleButton)) {
			object = parseSimpleButton(cast(source, SimpleButton));
		}
		else {
			var bitmapData = Blitter.toBitmapData(source);
			object = new Image(Texture.fromBitmapData(bitmapData));
		}
		
		object.transformationMatrix = source.transform.matrix;
		var coords = source.localToGlobal(new Point(0, 0));
		object.x = coords.x; object.y = coords.y;
		
		current.addChild(object);
	}
	
	private function parseTextField(source:flash.text.TextField):starling.text.TextField {
		var bounds:Rectangle = source.getBounds(source);
		var width:Int = Std.int(bounds.width);
		var height:Int = Std.int(bounds.height);
		var textField:starling.text.TextField = new starling.text.TextField(width, height, source.text);
		return textField;
	}
	
	private function parseSimpleButton(source:SimpleButton):Button {
		var upState = Texture.fromBitmapData(Blitter.toBitmapData(source.upState));
		var downState = Texture.fromBitmapData(Blitter.toBitmapData(source.downState));
		return new Button(upState, "", downState);
	}
	
	private function parseAnimation(movie:flash.display.MovieClip):Void {
		var textures:Vector<Texture> = new Vector<Texture>();
		var bounds:Rectangle = new Rectangle();
		for (frame in 1...(movie.totalFrames + 1)) {
			movie.gotoAndStop(frame);
			bounds = bounds.union(movie.getBounds(movie));
		}
		for (frame in 1...(movie.totalFrames + 1)) {
			movie.gotoAndStop(frame);
			var bitmapData = Blitter.toBitmapData(movie, bounds);
			textures.push(Texture.fromBitmapData(bitmapData));
		}
		var m:starling.display.MovieClip = new starling.display.MovieClip(textures, 30);
		m.transformationMatrix = movie.transform.matrix;
		current.addChild(m);
		Starling.juggler.add(m);
	}
	
	private function isAnimation(object:flash.display.DisplayObject):Bool {
		if (!Std.is(object, flash.display.MovieClip)) { return false; }
		
		var metaData:Dynamic = untyped object.metaData;
		return (metaData != null && Reflect.hasField(metaData, "anime"));
	}
	
	private function isTexture(object:flash.display.DisplayObject):Bool {
		if (!Std.is(object, flash.display.DisplayObjectContainer)) {
			return true;
		}
		
		var container:flash.display.DisplayObjectContainer = cast(object, flash.display.DisplayObjectContainer);
		for (index in 0...container.numChildren) {
			var child:flash.display.DisplayObject = container.getChildAt(index);
			if (Std.is(child, flash.text.TextField))	return false;
			if (Std.is(child, flash.display.MovieClip))	return false;
			if (Std.is(child, flash.display.Sprite))	return false;
			if (Std.is(child, flash.display.SimpleButton))	return false;
		}
		return true;
	}
	
}