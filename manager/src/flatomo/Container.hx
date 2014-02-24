package flatomo;

import starling.animation.IAnimatable;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

using flatomo.SectionTools;

// TODO : 将来、コンテナの親（継承関係）は starling.display.Sprite に置き換わる可能性があります。

/**
 * フレームとセクションで構成される表示オブジェクトコンテナ機能を提供する。
 * すべての表示オブジェクトは、再生ヘッドの位置に関係なく常にコンテナに追加されている。この性質上、子へのアクセスは再生ヘッドの到達を待つ必要がない。
 * ただし、コンテナの中で1つのインスタンス名（InstanceName、Element#name(JSFL)）に対応する表示オブジェクトは、唯一1つだけでなければならない。
 */
class Container extends DisplayObjectContainer implements IAnimatable implements IPlayhead {
	
	/**
	 * コンテナを生成する。
	 * @param	displayObjects コンテナに配置される表示オブジェクトのリスト。
	 * @param	map 「再生ヘッドの位置」と「そのフレームに配置された表示オブジェクトの配置情報のリスト」の対応関係。
	 * @param	sections セクション情報。
	 */
	public function new(displayObjects:Array<DisplayObject>, map:Map<Int, Array<Layout>>, sections:Array<Section>) {
		super();
		this.map = map;
		this.playhead = new Playhead(update, sections);
		
		// すべての表示オブジェクトは、再生ヘッドの位置に関係なく常にコンテナに追加されている。
		for (object in displayObjects) {
			// TODO : ジャグラーに登録しないとコンテナは可視状態にならない
			object.visible = false;
			this.addChild(object);
		}
	}
	
	/**
	 * 「再生ヘッドの位置」と「そのフレームに配置された表示オブジェクトの配置情報のリスト」の対応関係。
	 * @key 再生ヘッドの位置
	 * @value 再生ヘッドのいちに対応する配置された表示オブジェクトの配置情報のリスト
	 */
	private var map:Map</*Frame*/Int, Array<Layout>>; // TODO : 不適切な命名
	
	public var playhead(default, null):Playhead;
	
	public function advanceTime(time:Float):Void {
		playhead.advanceFrame(Std.int(time));
	}
	
	private function update():Void {
		// すべての表示オブジェクトを不可視状態にする。
		for (index in 0...numChildren) {
			this.getChildAt(index).visible = false;
		}
		
		// 現在の再生ヘッド位置に対応する表示オブジェクトの位置情報を取得して子に適応する。
		if (map.exists(playhead.currentFrame)) {
			var layouts:Array<Layout> = map.get(playhead.currentFrame);
			for (layout in layouts) {
				var child:DisplayObject = this.getChildByName(layout.instanceName);
				// TODO : Layout の変更に弱いのでこれを修正する。
				child.visible = true;
				child.x = layout.x;
				child.y = layout.y;
				child.rotation = layout.rotation;
				child.scaleX = layout.scaleX;
				child.scaleY= layout.scaleY;
			}
		}
	}
	
}
