package flatomo.extension;
import com.bit101.components.CheckBox;
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.VScrollBar;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flatomo.FlatomoItem;
import flatomo.Section;

class ContentViewer extends Sprite {
	
	private var canvas:Sprite;
	public var canvasSectionViewer(default, null):Sprite;
	public var canvasAnimationViewer(default, null):Sprite;
	
	private var animationViewer:CheckBox;
	private var sectionViewer:Array<SectionViewer>;
	
	private var scrollBar:VScrollBar;
	
	private var changed:Event -> Void;

	public function new(changed:Event -> Void) {
		super();
		this.changed = changed;
		
		this.canvasAnimationViewer = new Sprite();
		this.canvasSectionViewer = new Sprite();
		canvas = new Sprite();
		canvas.scrollRect = new Rectangle();
		addChild(canvas);
		canvas.addChild(canvasAnimationViewer);
		canvas.addChild(canvasSectionViewer);
		
		scrollBar = new VScrollBar(this, 0, 5, onScroll);
		resize();
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
	}
	
	private function resize(?event:Event = null):Void {
		scrollBar.x = Lib.current.stage.stageWidth - 15;
		canvas.scrollRect = new Rectangle(canvas.scrollRect.x, canvas.scrollRect.y, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight - this.y);
		scrollBar.setSize(scrollBar.width, canvas.scrollRect.height - 10);
		scrollBar.maximum = (canvasSectionViewer.height + canvasAnimationViewer.height) - canvas.scrollRect.height + 30;
		scrollBar.setThumbPercent(canvas.scrollRect.height / (canvasSectionViewer.height + canvasAnimationViewer.height));
	}
	
	private function mouseWheel(event:Dynamic):Void {
		var rectangle:Rectangle = canvas.scrollRect;
		rectangle.y -= event.delta * 7;
		rectangle.y = Math.min(rectangle.y, (canvasAnimationViewer.height + canvasSectionViewer.height) - canvas.scrollRect.height + 30);
		rectangle.y = Math.max(rectangle.y, 0);
		canvas.scrollRect = rectangle;
		scrollBar.value = rectangle.y;
	}
	
	private function onScroll(event:Dynamic):Void {
		canvas.scrollRect = new Rectangle(0, scrollBar.value, canvas.scrollRect.width, canvas.scrollRect.height);
	}
	
	public function update(isAnimation:Bool, sections:Array<Section>, names:Array<String>, kinds:Array<String>):Void {
		animationViewer = new CheckBox(canvasAnimationViewer, 5, 10, "タイムラインをパラパラ漫画化する", changed);
		animationViewer.selected = isAnimation;
		
		sectionViewer = new Array<SectionViewer>();
		for (index in 0...sections.length) {
			var section:Section = sections[index];
			var viewer:SectionViewer = new SectionViewer(canvasSectionViewer, 5, 30 + 35 * index, section, names, kinds);
			viewer.addEventListener(SectionViewer.CHANGED, changed);
			sectionViewer.push(viewer);
		}
		resize();
	}
	
	public function clear():Void {
		canvasSectionViewer.removeChildren();
		canvasAnimationViewer.removeChildren();
	}
	
	public function flatomoDisabled():Void {
		clear();
		new Label(canvasSectionViewer, 5, 10, "Flatomoが使えないドキュメントかFlatomoが無効です");
	}
	
	public function disabledTimlineSelected():Void {
		clear();
		new Label(canvasSectionViewer, 5, 10, "対応していないタイムラインです");
	}
	
	public function toFlatomoItem():FlatomoItem {
		var sections:Array<Section> = new Array<Section>();
		for (index in 0...sectionViewer.length) {
			var viewer:SectionViewer = sectionViewer[index];
			sections.push(viewer.fetchLatestSection());
		}
		return { sections: sections, animation: animationViewer.selected };
	}
	
}
