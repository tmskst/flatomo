package flatomo;
import flash.events.Event;
import flash.Lib;
import haxe.PosInfos;
import starling.animation.Juggler;
import starling.display.DisplayObject;
import starling.display.Image;

class Flatomo {
	
	/**
	 * Flatomoを初期化する。
	 * @param	config FlatomoExtensionで生成された設定オブジェクト。
	 */
	public static function start(config:flash.display.DisplayObjectContainer):Void {
		if (isStarted) { return; }
		
		Flatomo.isStarted = true;
		Flatomo.library = FlatomoTools.fetchLibrary(config);
		Flatomo.sources = new Map<String, Source>();
	}
	
	/**
	 * flash.display.DisplayObject を starling.display.DisplayObject に変換する。
	 * @param	source 変換元となる表示オブジェクト(flash.display)
	 * @return 変換後の表示オブジェクト(starling.display)
	 */
	public static function create(source:flash.display.DisplayObject):Void {
		Creator.translate(source, "root");
	}
	
	private static var flatomo:Flatomo = null;
	private static var isStarted:Bool = false;
	
	public static var library(default, null):Map<String, FlatomoItem> = null;
	
	public static var sources(default, null):Map<String, Source>;
	
	public static function addSource(key:String, source:Source, ?posInfos:PosInfos):Void {
		trace('add ${key}', posInfos.className, posInfos.lineNumber);
		sources.set(key, source);
	}
	
	public static function exists(key:String):Bool {
		return sources.exists(key);
	}
	
	@:access(flatomo.Animation)
	@:access(faltomo.Container)
	public static function get(key:String):DisplayObject {
		var source:Source = Flatomo.sources.get(key);
		switch (source) {
			case Source.Animation(name, textures, sections) :
				var a = new Animation(textures, sections);
				a.name = name;
				return a;
			case Source.Container(name, keys, map, sections) :
				var displayObjects:Array<DisplayObject> = new Array<DisplayObject>();
				for (t in keys) {
					displayObjects.push(Flatomo.get(t));
				}
				var c = new Container(displayObjects, map, sections);
				c.name = name;
				return c;
			case Source.Texture(name, texture) :
				var image = new Image(texture);
				image.name = name;
				return image;
		}
	}
}
