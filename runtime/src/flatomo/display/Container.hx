package flatomo.display;

import flash.geom.Matrix;
import flash.Vector;
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
		
		this.m0 = new Matrix();
		this.m1 = new Matrix();
		
		// すべての表示オブジェクトは、再生ヘッドの位置に関係なく常にコンテナに追加されている。
		this.children = untyped Vector.ofArray(displayObjects);
		children.fixed = true;
		for (child in children) {
			child.visible = false;
			this.addChild(cast child);
		}
		update(1);
	}
	
	private var matrix:Matrix;
	private var layouts:Array<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
	private var children:Vector<ILayoutAdjusted>;
	
	private var m0:Matrix;
	private var m1:Matrix;
	
	/** 自身（表示オブジェクト）の更新 */
	public function update(currentFrame:Int):Void {
		for (child in children) {
			child.visible = false;
			var layout:Layout = child.layouts[currentFrame - 1];
			if (layout == null || child.visiblePropertyOverwrited && !child.visible) { continue; } 
			
			child.visible = true;
			
			if (child.layoutPropertiesOverwrited) { continue; }
			
			var depth:Int = this.getChildIndex(cast child);
			this.swapChildrenAt(depth, layout.depth);
			
			m1.a = layout.transform.a;
			m1.b = layout.transform.b;
			m1.c = layout.transform.c;
			m1.d = layout.transform.d;
			m1.tx = layout.transform.tx;
			m1.ty = layout.transform.ty;
			
			m0.a = child.matrix.a;
			m0.b = child.matrix.b;
			m0.c = child.matrix.c;
			m0.d = child.matrix.d;
			m0.tx = child.matrix.tx;
			m0.ty = child.matrix.ty;
			
			m0.invert();
			m0.concat(m1);
			
			child.transformationMatrix = m0;
		}
	}
	
	public override function dispose():Void {
		this.matrix = null;
		this.layouts = null;
		this.children = null;
		super.dispose();
	}
}
