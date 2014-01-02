package flatomo;
import flash.events.Event;
import flash.Lib;
import starling.animation.Juggler;
import starling.display.DisplayObject;

class Flatomo {
	
	/**
	 * Flatomoを初期化する。
	 * @param	config FlatomoExtensionで生成された設定オブジェクト。
	 */
	public static function start(config:flash.display.DisplayObjectContainer):Void {
		if (isStarted) { return; }
		
		Flatomo.isStarted = true;
		Flatomo.juggler = new Juggler();
		Flatomo.library = FlatomoTools.fetchLibrary(config);
		Flatomo.flatomo = new Flatomo();
	}
	
	/**
	 * flash.display.DisplayObject を starling.display.DisplayObject に変換する。
	 * @param	source 変換元となる表示オブジェクト(flash.display)
	 * @return 変換後の表示オブジェクト(starling.display)
	 */
	public static function create(source:flash.display.DisplayObject):DisplayObject {
		return Creator.translate(source);
	}
	
	private static var flatomo:Flatomo = null;
	private static var isStarted:Bool = false;
	
	/**
	 * Flatomoが管理するジャグラー。
	 * ステージの Event.ENTER_FRAME が送出されるたびにジャグラーは更新される。
	 */
	public static var juggler(default, null):Juggler = null;
	public static var library(default, null):Map<String, FlatomoItem> = null;
	
	private function new() {
		Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:flash.events.Event):Void {
		juggler.advanceTime(1.00);
	}
	
}
