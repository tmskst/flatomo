package ;
import flash.display.Loader;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flatomo.Creator;
import flatomo.Flatomo;
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
		var symbol:Dynamic = Type.createInstance(Type.resolveClass("Test"), []);
		
		Flatomo.start();
		
		var object = Flatomo.create(symbol);
		this.addChild(object);
	}
	
}
