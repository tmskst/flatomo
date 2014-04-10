package flatomo.display;

import de.polygonal.ds.ListSet;
import de.polygonal.ds.Set;
import flatomo.display.ILayoutAdjusted;
import flatomo.display.LayoutAdjustedTools;
import haxe.ds.Vector;
import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

using flatomo.SectionTools;

// TODO : 将来、コンテナの親（継承関係）は starling.display.Sprite に置き換わる可能性があります。

/**
 * フレームとセクションで構成される表示オブジェクトコンテナ機能を提供する。
 * すべてのコンテナの子は、コンテナの生成と同時に追加（addChild）される。
 * また、コンテナ内のインスタンス名（Element#name）は、1つの表示オブジェクトに対応する。
 * この性質上、再生ヘッドの到達を待つことなく任意の子へのアクセスができる。
 */
class Container extends DisplayObjectContainer implements ILayoutAdjusted implements IAnimatable implements IPlayhead {
	
	/**
	 * コンテナを生成する。
	 * 呼び出しは flatomo.FlatomoAssetManager に制限される。
	 * @param	displayObjects コンテナに配置される表示オブジェクトのリスト。
	 * @param	map 「再生ヘッドの位置」と「そのフレームに配置された表示オブジェクトの配置情報のリスト」の対応関係。
	 * @param	sections セクション情報。
	 */
	@:allow(flatomo.FlatomoAssetManager)
	private function new(layouts:Vector<Layout>, displayObjects:Array<DisplayObject>, sections:Array<Section>) {
		super();
		this.locked = false;
		this.layouts = layouts;
		this.playhead = new Playhead(update, sections);
		
		// すべての表示オブジェクトは、再生ヘッドの位置に関係なく常にコンテナに追加されている。
		for (object in displayObjects) {
			// FIXME : ジャグラーに登録しないとコンテナは可視状態にならない
			object.visible = false;
			this.addChild(object);
		}
	}
	
	private var locked:Bool;
	private var layouts:Vector<Layout>;
	
	/** 再生ヘッド */
	public var playhead(default, null):Playhead;
	
	/**
	 * 再生ヘッドを進める
	 * @param	time 今は使用しない
	 */
	public function advanceTime(time:Float):Void {
		playhead.advanceFrame(Std.int(time));
	}
	
	/** 自身（表示オブジェクト）の更新 */
	private function update():Void {
		// すべての表示オブジェクトを不可視状態にする。
		for (index in 0...numChildren) {
			this.getChildAt(index).visible = false;
		}
		
		for (childIndex in 0...numChildren) {
			var child = this.getChildAt(childIndex);
			LayoutAdjustedTools.update(cast child, playhead.currentFrame);
		}
		
		/*
		// 現在の再生ヘッド位置に対応する表示オブジェクトの位置情報を取得して子に適応する。
		if (layouts.exists(playhead.currentFrame)) {
			var layouts:Array<Layout> = layouts.get(playhead.currentFrame);
			for (layout in layouts) {
				var child:DisplayObject = this.getChildByName(layout.instanceName);
				// TODO : Layout の変更に弱いのでこれを修正する。
				child.visible = true;
				
				// ロックされた表示オブジェクトは更新しない。
				if (!locked.has(layout.instanceName)) {
					child.x = layout.x;
					child.y = layout.y;
					child.rotation = layout.rotation;
					child.scaleX = layout.scaleX;
					child.scaleY = layout.scaleY;
				}
			}
		}
		*/
	}
	
}
