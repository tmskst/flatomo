package flatomo;

import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

using Lambda;
using flatomo.SectionTools;

class Container extends DisplayObjectContainer implements IAnimatable {
	
	public function new(displayObjects:Array<DisplayObject>, map:Map<Int, Array<Layout>>, sections:Array<Section>) {
		super();
		this.map = map;
		this.codes = sections.toControlCodes();
		this.currentFrame = 1;
		this.isPlaying = true;
		
		for (object in displayObjects) {
			this.addChild(object);
		}
	}
	
	private var map:Map<Int, Array<Layout>>;
	private var codes:Map<Int, ControlCode>;
	
	public var currentFrame(default, null):Int;
	public var isPlaying(default, null):Bool;
	
	public function advanceTime(time:Float):Void {
		if (!isPlaying) { return; }
		
		if (codes.exists(currentFrame)) {
			switch (codes.get(currentFrame)) {
				case ControlCode.Goto(frame) :
					this.currentFrame = frame;
				case ControlCode.Stop : 
					this.isPlaying = false;
					return;
			}
		} else {
			this.currentFrame = currentFrame + 1;
		}
		
		for (index in 0...numChildren) {
			this.getChildAt(index).visible = false;
		}
		
		var layouts:Array<Layout> = map.get(currentFrame);
		for (layout in layouts) {
			var child:DisplayObject = this.getChildByName(layout.instanceName);
			child.visible = true;
			child.x = layout.x;
			child.y = layout.y;
		}
		
	}
	
}
