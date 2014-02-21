package flatomo;
import starling.display.DisplayObject;

/**
 * コンテナの生成手段を提供する。
 */
@:allow(flatomo.Creator)
class ContainerCreator {
	
	/**
	 * 対象がコンテナかどうかを判定する。
	 * @param	source 判定の対象。
	 * @return 対象がコンテナなら真。
	 */
	private static function isAlliedTo(source:flash.display.DisplayObject):Bool {
		/*
		 * コンテナである条件は、
		 * 1. 対象は flash.display.DisplayObjectContainerであること。
		 */
		return Std.is(source, flash.display.DisplayObjectContainer);
	}
	
	/**
	 * flash.display.DisplayObjectContainer とセクション情報を元にコンテナを作成する。
	 * @param	source コンテナの元となる表示オブジェクトコンテナ。
	 * @param	sections コンテナの再生ヘッドを制御するセクション情報。
	 * @return 生成されたコンテナ。
	 */
	private static function create(source:flash.display.DisplayObjectContainer, sections:Array<Section>, path:String, flatomo:Flatomo):Void {
		// TODO : 現在、flash.display.Sprite と flash.display.Loader に対応していません。
		if (flatomo.sources.exists(FlatomoTools.fetchLibraryPath(source))) { return; }
		
		// flash.display.MovieClip をコンテナに変換する
		var movie:flash.display.MovieClip = cast(source, flash.display.MovieClip);
		var map = new Map<Int, Array<Layout>>();
		var displayObjects = new Array<String>();
		
		// 全フレームを走査
		for (frame in 0...movie.totalFrames) {
			movie.gotoAndStop(frame + 1);
			
			// フレーム中の全ての表示オブジェクトを走査
			var layouts = new Array<Layout>();
			for (index in 0...movie.numChildren) {
				var child:flash.display.DisplayObject = movie.getChildAt(index);
				displayObjects.push(FlatomoTools.fetchLibraryPath(child));
				Creator.translate(child, FlatomoTools.fetchLibraryPath(source), flatomo);
				layouts.push( {
					instanceName: child.name,
					libraryPath: /*FlatomoTools.fetchElement(child).libraryPath*/'',
					x: child.x,
					y: child.y,
					rotation: untyped { __global__["starling.utils.deg2rad"](child.rotation); } ,
					scaleX: child.scaleX,
					scaleY: child.scaleY
				} );
			}
			map.set(frame + 1, layouts);
		}
		
		// コンテナを生成
		flatomo.sources.set(FlatomoTools.fetchLibraryPath(source), Source.Container(source.name, displayObjects, map, sections));
	}
	
}
