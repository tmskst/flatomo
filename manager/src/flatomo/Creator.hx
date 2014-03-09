package flatomo;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Rectangle;

using flatomo.Creator.DisplayObjectTools;

typedef Image = { name:String, image:BitmapData };

@:allow(flatomo.Flatomo)
class Creator {
	
	public static function create(library:FlatomoLibrary, classes:Array<Class<DisplayObject>>):{ images:Array<{ name:String, image:BitmapData }>, meta:Map<String, Meta> } {
		var creator:Creator = new Creator(library);
		for (clazz in classes) {
			creator.translate(Type.createInstance(clazz, []), "F:" + Type.getClassName(clazz));
		}
		return { images: creator.images, meta: creator.meta };
	}
	
	private function new(library:FlatomoLibrary) {
		this.library = library;
		this.images = new Array<Image>();
		this.meta = new Map<String, Meta>();
	}
	
	private var library:FlatomoLibrary;
	private var images:Array<Image>;
	private var meta:Map<String, Meta>;
	
	
	/**
	 * 表示オブジェクト（flash.display.DisplayObject）を解析します
	 * @param	source 解析する表示オブジェクト
	 * @param	path 対象のライブラリパス
	 */
	private function translate(source:DisplayObject, libraryPath:String):Void {
		// libraryPath = F:MainScene or Game/Foobar etc
		if (meta.exists(libraryPath)) { return; }
		
		var type = source.fetchDisplayObjectType(libraryPath, library);
		switch (type) {
			case DisplayObjectType.Animation : translateQuaAnimation(cast(source, MovieClip), libraryPath);
			case DisplayObjectType.Container : translateQuaContainer(cast(source, MovieClip), libraryPath);
			case DisplayObjectType.Image : translateQuaImage(source, libraryPath);
		}
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Animationとして解析します
	 * @param	source 対象の表示オブジェクト
	 */
	private function translateQuaAnimation(source:MovieClip, libraryPath:LibraryPath):Void {
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
			images.push({ name: '${libraryPath} ${index}', image: Blitter.toBitmapData(source, bounds) });
		}
		var sections = library.metadata.get(libraryPath).sections;
		meta.set(libraryPath, Meta.Animation(sections, -bounds.x, -bounds.y));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Containerとして解析します
	 * @param	source 対象の表示オブジェクト
	 */
	private function translateQuaContainer(source:MovieClip, libraryPath:LibraryPath):Void {
		var map = new Map<Int, Array<Layout>>();
		var children = new Array<{ key:String, instanceName:String }>();
		
		// 全フレームを走査
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			
			// フレーム中の全ての表示オブジェクトを走査
			var layouts = new Array<Layout>();
			for (index in 0...source.numChildren) {
				var child:DisplayObject = source.getChildAt(index);
				var childType = child.fetchDisplayObjectType(libraryPath, library);
				var childKey:String = switch (childType) {
					case DisplayObjectType.Animation : child.fetchLibraryPath(libraryPath, library);
					case DisplayObjectType.Container : child.fetchLibraryPath(libraryPath, library);
					case DisplayObjectType.Image : '${libraryPath}#${child.name}';
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
		var sections = library.metadata.get(libraryPath).sections;
		meta.set(libraryPath, Meta.Container(children, map, sections));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Imageとして解析します
	 * @param	source 対象の表示オブジェクト
	 * @param	path 対象のライブラリパス
	 */
	private function translateQuaImage(source:DisplayObject, libraryPath:LibraryPath):Void {
		images.push({ name: libraryPath, image: Blitter.toBitmapData(source) });
		meta.set(libraryPath, Meta.Image);
	}
	
}

@:allow(flatomo.Creator)
class DisplayObjectTools {
	
	/**
	 * 対象（Instance)をインスタンス化するために使用されたライブラリパスを取り出す
	 * @param	instance 対象
	 * @return 対象をインスタンス化するために使用されたライブラリパス
	 */
	public static function fetchLibraryPath(instance:flash.display.DisplayObject, parentLibraryPath:LibraryPath, library:FlatomoLibrary):LibraryPath {
		return library.libraryPaths.get(parentLibraryPath + "#" +instance.name);
	}
	
	/**
	 * 表示オブジェクトが属するDisplayObjectTypeを返します
	 */
	private static function fetchDisplayObjectType(source:DisplayObject, libraryPath:LibraryPath, library:FlatomoLibrary):DisplayObjectType {
		if (source.isAlliedToAnimation(libraryPath, library)) {
			return DisplayObjectType.Animation;
		}
		if (source.isAlliedToContainer(libraryPath, library)) {
			return DisplayObjectType.Container;
		}
		
		return DisplayObjectType.Image;
	}
	
	/*
	 * アニメーションである条件は、
	 * 1. 対象がflash.display.MovieClipであること。
	 * 2. 対象のアニメーション属性が有効（真）であること。
	 */
	private static function isAlliedToAnimation(source:DisplayObject, libraryPath:LibraryPath, library:FlatomoLibrary):Bool {
		// 式をひとつまとめないでください。
		if (!Std.is(source, MovieClip)) { return false; }
		
		var item = library.metadata.get(libraryPath);
		return item != null && item.animation;
	}
	
	/*
	 * コンテナである条件は、
	 * 1. 対象は flash.display.DisplayObjectContainerであること。
	 */
	private static function isAlliedToContainer(source:DisplayObject, libraryPath:LibraryPath, library:FlatomoLibrary):Bool {
		return Std.is(source, DisplayObjectContainer);
	}
	
}

private enum DisplayObjectType {
	Animation;
	Container;
	Image;
}
