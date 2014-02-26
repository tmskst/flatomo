package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Rectangle;

using flatomo.FlatomoTools;
using flatomo.Creator.DisplayObjectTools;

@:allow(flatomo.Flatomo)
class Creator {
	
	public static function create(library:Map<String, FlatomoItem>, classes:Array<Class<DisplayObject>>):{ images:Array<{ name:String, image:BitmapData }>, meta:Map<String, Meta> } {
		var creator:Creator = new Creator(library);
		for (clazz in classes) {
			creator.translate(Type.createInstance(clazz, []), "root");
		}
		return { images: creator.images, meta: creator.meta };
	}
	
	private function new(library:Map<String, FlatomoItem>) {
		this.library = library;
		this.images = new Array<{name:String, image:BitmapData}>();
		this.meta = new Map<String, Meta>();
	}
	
	private var library:Map<String, FlatomoItem>;
	private var images:Array<{ name:String, image:BitmapData }>;
	private var meta:Map<String, Meta>;
	
	/**
	 * 表示オブジェクト（flash.display.DisplayObject）を解析します
	 * @param	source 解析する表示オブジェクト
	 * @param	path 対象のライブラリパス
	 */
	private function translate(source:DisplayObject, path:String):Void {
		var type = source.fetchDisplayObjectType(library);
		switch (type) {
			case DisplayObjectType.Animation : translateQuaAnimation(cast(source, MovieClip));
			case DisplayObjectType.Container : translateQuaContainer(cast(source, MovieClip));
			case DisplayObjectType.Image : translateQuaImage(source, path);
		}
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Animationとして解析します
	 * @param	source 対象の表示オブジェクト
	 */
	private function translateQuaAnimation(source:MovieClip):Void {
		var key:String = FlatomoTools.fetchLibraryPath(source);
		if (meta.exists(key)) { return; }
		var sections = library.fetchItem(source).sections;
		
		// ソースの描画領域を計算
		var bounds:Rectangle = new Rectangle();
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			bounds = bounds.union(source.getBounds(source));
		}
		// テクスチャを生成
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			var index = ("00000" + Std.string(frame)).substr(-5);
			images.push({ name: '${key} ${index}', image: Blitter.toBitmapData(source, bounds) });
		}
		
		meta.set(key, Meta.Animation(sections, -bounds.x, -bounds.y));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Containerとして解析します
	 * @param	source 対象の表示オブジェクト
	 */
	private function translateQuaContainer(source:MovieClip):Void {
		var key:String = FlatomoTools.fetchLibraryPath(source);
		if (meta.exists(key)) { return; }
		
		var map = new Map<Int, Array<Layout>>();
		var children = new Array<{ key:String, instanceName:String }>();
		
		// 全フレームを走査
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			
			// フレーム中の全ての表示オブジェクトを走査
			var layouts = new Array<Layout>();
			for (index in 0...source.numChildren) {
				var child:DisplayObject = source.getChildAt(index);
				var childType = child.fetchDisplayObjectType(library);
				var childKey:String = switch (childType) {
					case DisplayObjectType.Animation : child.fetchLibraryPath();
					case DisplayObjectType.Container : child.fetchLibraryPath();
					case DisplayObjectType.Image : '${key}#${child.name}';
				}
				children.push({ key: childKey, instanceName: child.name });
				translate(child, childKey);
				
				layouts.push({
					instanceName: child.name,
					x: child.x,
					y: child.y,
					rotation: untyped { __global__["starling.utils.deg2rad"](child.rotation); } ,
					scaleX: child.scaleX,
					scaleY: child.scaleY
				});
			}
			map.set(frame + 1, layouts);
		}
		var sections = library.fetchItem(source).sections;
		meta.set(key, Meta.Container(children, map, sections));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Imageとして解析します
	 * @param	source 対象の表示オブジェクト
	 * @param	path 対象のライブラリパス
	 */
	private function translateQuaImage(source:DisplayObject, path:String):Void {
		var key:String = path;
		if (meta.exists(key)) { return; }
		
		images.push({ name: key, image: Blitter.toBitmapData(source) });
		meta.set(key, Meta.Image);
	}
	
}

@:allow(flatomo.Creator)
class DisplayObjectTools {
	
	/**
	 * 表示オブジェクトが属するDisplayObjectTypeを返します
	 */
	private static function fetchDisplayObjectType(source:DisplayObject, library:Map<String, FlatomoItem>):DisplayObjectType {
		if (source.isAlliedToAnimation(library)) {
			return DisplayObjectType.Animation;
		}
		if (source.isAlliedToContainer()) {
			return DisplayObjectType.Container;
		}
		
		return DisplayObjectType.Image;
	}
	
	/*
	 * アニメーションである条件は、
	 * 1. 対象がflash.display.MovieClipであること。
	 * 2. 対象のアニメーション属性が有効（真）であること。
	 */
	private static function isAlliedToAnimation(source:DisplayObject, library:Map<String, FlatomoItem>):Bool {
		// 式をひとつまとめないでください。
		if (!Std.is(source, MovieClip)) { return false; }
		
		var item:FlatomoItem = library.fetchItem(source);
		return item != null && item.animation;
	}
	
	/*
	 * コンテナである条件は、
	 * 1. 対象は flash.display.DisplayObjectContainerであること。
	 */
	private static function isAlliedToContainer(source:DisplayObject):Bool {
		return Std.is(source, DisplayObjectContainer);
	}
	
}

private enum DisplayObjectType {
	Animation;
	Container;
	Image;
}
