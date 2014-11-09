package flatomo.display;

import flash.geom.Matrix;
import flatomo.display.ILayoutAdjusted;
import flatomo.GpuOperator;
import flatomo.Layout;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

using flatomo.display.SectionTools;

/**
 * フレームとセクションで構成される表示オブジェクトコンテナ機能を提供する。
 * すべてのコンテナの子は、生成と同時にコンテナに追加（addChild）される。
 * 1つのインスタンス名（任意のコンテナの子の名前）は、1つの表示オブジェクトに対応し、
 * この性質上、再生ヘッドの到達を待つことなく任意の子へアクセスすることができる。
 */
class Container extends DisplayObjectContainer implements ILayoutAdjusted {
	
	/**
	 * コンテナを生成する。
	 * 呼び出しは flatomo.GpuOperator に制限される。
	 * @param	displayObjects コンテナに配置される表示オブジェクトのリスト。
	 * @param	map 「再生ヘッドの位置」と「そのフレームに配置された表示オブジェクトの配置情報のリスト」の対応関係。
	 * @param	sections セクション情報。
	 */
	@:allow(flatomo.GpuOperator)
	private function new(layouts:Array<Layout>, displayObjects:Array<DisplayObject>) {
		super();
		this.matrix = new Matrix();
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
		
		
		// すべての表示オブジェクトは、再生ヘッドの位置に関係なく常にコンテナに追加されている。
		for (object in displayObjects) {
			object.visible = false;
			this.addChild(object);
		}
		update(1);
	}
	
	private var matrix:Matrix;
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
	/** 自身（表示オブジェクト）の更新 */
	public function update(currentFrame:Int):Void {
		// 自身の子のうち制御可能な表示オブジェクトのリスト
		var children = new Array<ILayoutAdjusted>();
		for (childIndex in 0...numChildren) {
			var child:DisplayObject = this.getChildAt(childIndex);
			if (Std.is(child, ILayoutAdjusted)) {
				child.visible = false;
				children.push(cast child);
			}
		}
		
		for (child in children) {
			var layout:Layout = child.layouts[currentFrame - 1];
			if (layout == null || child.visiblePropertyOverwrited && !child.visible) { continue; } 
			
			child.visible = true;
			
			if (child.layoutPropertiesOverwrited) { continue; }
			
			var depth:Int = this.getChildIndex(cast child);
			this.swapChildrenAt(depth, layout.depth);
			var x = new Matrix(
				layout.transform.a, layout.transform.b,
				layout.transform.c, layout.transform.d,
				layout.transform.tx, layout.transform.ty
			);
			var m = child.matrix.clone();
			m.invert();
			m.concat(x);
			child.transformationMatrix = m;
		}
	}
	
	public override function dispose():Void {
		this.matrix = null;
		this.layouts = null;
		super.dispose();
	}
}
