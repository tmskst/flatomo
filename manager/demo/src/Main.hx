package ;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flatomo.Flatomo;
import starling.display.DisplayObject;
import starling.display.Sprite;

class Main extends Sprite {
	
	public function new() {
		super();
		var ASSET_PATH = "library.swf";
		
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, deploy);
		loader.load(
			new URLRequest(ASSET_PATH),
			new LoaderContext(false, ApplicationDomain.currentDomain)
		);
	}
	
	private function deploy(event:Event):Void {
		Flatomo.start(Type.createInstance(Type.resolveClass("Config"), []));
		var object:DisplayObject = Flatomo.create(Type.createInstance(Type.resolveClass("TestMovie"), []));
		this.addChild(object);
	}
	
}
