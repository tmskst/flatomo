package flatomo.display;

import flatomo.display.ILayoutAdjusted;
import flatomo.display.LayoutAdjustedTools;
import flatomo.GpuOperator;
import flatomo.Layout;
import haxe.ds.Vector;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

using flatomo.display.SectionTools;

// TODO : 将来、コンテナの親（継承関係）は starling.display.Sprite に置き換わる可能性があります。

/**
 * フレームとセクションで構成される表示オブジェクトコンテナ機能を提供する。
 * すべてのコンテナの子は、コンテナの生成と同時に追加（addChild）される。
 * また、コンテナ内のインスタンス名（Element#name）は、1つの表示オブジェクトに対応する。
 * この性質上、再生ヘッドの到達を待つことなく任意の子へのアクセスができる。
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
	private function new(layouts:Vector<Layout>, displayObjects:Array<DisplayObject>, sections:Array<Section>) {
		super();
		this.layouts = layouts;
		this.layoutPropertiesOverwrited = false;
		this.visiblePropertyOverwrited = false;
		
		// すべての表示オブジェクトは、再生ヘッドの位置に関係なく常にコンテナに追加されている。
		for (object in displayObjects) {
			// FIXME : ジャグラーに登録しないとコンテナは可視状態にならない
			object.visible = false;
			this.addChild(object);
		}
		update(1);
	}
	
	private var layouts:Vector<Layout>;
	private var layoutPropertiesOverwrited:Bool;
	private var visiblePropertyOverwrited:Bool;
	
	/** 自身（表示オブジェクト）の更新 */
	public function update(currentFrame:Int):Void {
		// すべての表示オブジェクトを不可視状態にする。
		for (childIndex in 0...numChildren) {
			var child = this.getChildAt(childIndex);
			if (Std.is(child, ILayoutAdjusted)) {
				LayoutAdjustedTools.update(cast child, currentFrame);
			}
		}
		
	}
	
}
