package flatomo;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

using Lambda;

class Container extends DisplayObjectContainer implements IAnimatable {
	
	public function new(keyFrames:Array<KeyFrame>, elements:Map<String, DisplayObject>) {
		super();
		this.currentFrame = 1;
		this.totalFrames = 1;
		
		this.keyFrames = keyFrames;
		for (keyFrame in keyFrames) {
			totalFrames = Std.int(Math.max(totalFrames, keyFrame.end));
		}
		
		this.elements = elements;
		for (element in elements) {
			this.addChild(element);
		}
		
		goto(currentFrame);
	}
	
	private var keyFrames:Array<KeyFrame>;
	private var elements:Map<String, DisplayObject>;
	
	private var currentFrame:Int;
	private var totalFrames:Int;
	
	public function advanceTime(time:Float):Void {
		currentFrame = if (currentFrame == totalFrames) 1 else currentFrame + 1;
		goto(currentFrame);
	}
	
	public function goto(frame:Int):Void {
		var frames:Array<KeyFrame> = keyFrames.filter(
			function (f:KeyFrame) { return f.start <= frame && frame <= f.end; }
		);
		
		for (element in elements) {
			element.visible = false;
		}
		
		for (keyFrame in frames) {
			for (element in keyFrame.elements) {
				var obj:DisplayObject = elements.get(element.name);
				obj.x = element.layout.x;
				obj.y = element.layout.y;
				obj.visible = true;
			}
		}
	}
	
}
