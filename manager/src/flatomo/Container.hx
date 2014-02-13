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
class Container extends DisplayObjectContainer implements IAnimatable {
	
	/**
	 * コンテナを生成する。
	 * @param	displayObjects コンテナに配置される表示オブジェクトのリスト。
	 * @param	map 「再生ヘッドの位置」と「そのフレームに配置された表示オブジェクトの配置情報のリスト」の対応関係。
	 * @param	sections セクション情報。
	 */
	@:allow(flatomo.ContainerCreator)
	public function new(displayObjects:Array<DisplayObject>, map:Map<Int, Array<Layout>>, sections:Array<Section>) {
		super();
		this.map = map;
		this.codes = sections.toControlCodes();
		this.currentFrame = 1;
		this.nextFrame = 1;
		this.isPlaying = true;
		
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
	
	/**
	 * 再生ヘッドを制御するための制御コード
	 * @key　フレーム番号（再生ヘッドの位置）
	 * @value　フレームに対応する制御コード
	 */
	private var codes:Map</*Frame*/Int, ControlCode>;
	
	/** 現在の再生ヘッドの位置 */
	public var currentFrame(default, null):Int;
	
	private var nextFrame:Int;
	
	/** 再生中かどうか */
	public var isPlaying(default, null):Bool;
	
	/**
	 * 再生ヘッドを1フレーム進める。
	 * 制御コードによって再生ヘッドが移動したり停止する可能性がある。
	 * @param	time 利用しない
	 */
	public function advanceTime(time:Float):Void {
		if (!isPlaying) { return; }
		
		this.currentFrame = nextFrame;
		
		/*
		 * 描画処理
		 * 最も簡単な実装です。最適化はされていません
		 */
		
		// すべての表示オブジェクトを不可視状態にする。
		for (index in 0...numChildren) {
			this.getChildAt(index).visible = false;
		}
		
		// 現在の再生ヘッド位置に対応する表示オブジェクトの位置情報を取得して子に適応する。
		if (map.exists(currentFrame)) {
			var layouts:Array<Layout> = map.get(currentFrame);
			for (layout in layouts) {
				var child:DisplayObject = this.getChildByName(layout.instanceName);
				// TODO : Layout の変更に弱いのでこれを修正する。
				child.visible = true;
				child.x = layout.x;
				child.y = layout.y;
			}
		}
		
		/*
		 * 制御コード処理
		 */
		nextFrame = nextFrame + 1;
		if (codes.exists(currentFrame)) {
			switch (codes.get(currentFrame)) {
				case ControlCode.Goto(frame) :
					nextFrame = frame;
				case ControlCode.Stop : 
					this.isPlaying = false;
			}
		}
		
	}
	
}
