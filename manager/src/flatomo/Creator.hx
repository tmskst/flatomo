package flatomo;
import flash.accessibility.Accessibility;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flatomo.AtlasGenerator.Mint;

using flatomo.Creator;
using flatomo.FlatomoTools;

/**
 * flash.display.DisplayObject を starling.display.DisplayObject に変換する機能を提供する。
 */
@:allow(flatomo.Flatomo)
class Creator {
	
	public static function create(library:Map<String, FlatomoItem>, classes:Array<Class<DisplayObject>>):{ images:Array<Mint>, meta:Map<String, Meta> } {
		var creator:Creator = new Creator(library);
		for (clazz in classes) {
			creator.translate(Type.createInstance(clazz, []), "root");
		}
		return { images: creator.images, meta: creator.meta };
	}
	
	// TODO : 現在、テクスチャアトラスには対応していません。
	
	/**
	 * flash.display.DisplayObject を starling.display.DisplayObject に変換する。
	 * @param	source 変換元となる表示オブジェクト(flash.display)
	 * @return 変換後の表示オブジェクト(starling.display)
	 */
	
	private function new(library:Map < String, FlatomoItem > ) {
		this.library = library;
		this.images = new Array<Mint>();
		this.meta = new Map<String, Meta>();
	}
	
	private var library:Map<String, FlatomoItem>;

	private var images:Array<Mint>;
	private var meta:Map<String, Meta>;
	
	private function translate(source:flash.display.DisplayObject, path:String):Void {
		var kind = source.fetchDisplayObjectKind(library);
		switch (kind) {
			case DisplayObjectKind.Animation : translateQuaAnimation(cast(source, MovieClip));
			case DisplayObjectKind.Container : translateQuaContainer(cast(source, MovieClip));
			case DisplayObjectKind.Image : translateQuaImage(source, path);
		}
	}
	
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
		
		meta.set(key, Meta.Animation(sections));
	}
	
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
				var childKind = child.fetchDisplayObjectKind(library);
				var childKey:String = switch (childKind) {
					case DisplayObjectKind.Animation : child.fetchLibraryPath();
					case DisplayObjectKind.Container : child.fetchLibraryPath();
					case DisplayObjectKind.Image : '${key}#${child.name}';
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
	
	private function translateQuaImage(source:DisplayObject, path:String):Void {
		var key:String = path;
		if (meta.exists(key)) { return; }
		
		images.push({ name: key, image: Blitter.toBitmapData(source) });
		meta.set(key, Meta.Image);
	}
	
	private static function fetchDisplayObjectKind(source:DisplayObject, library:Map<String, FlatomoItem>):DisplayObjectKind {
		if (source.isAlliedToAnimation(library)) {
			return DisplayObjectKind.Animation;
		}
		if (source.isAlliedToContainer()) {
			return DisplayObjectKind.Container;
		}
		
		return DisplayObjectKind.Image;
	}
	
	private static function isAlliedToAnimation(source:flash.display.DisplayObject, library:Map<String, FlatomoItem>):Bool {
		/*
		 * アニメーションである条件は、
		 * 1. 対象がflash.display.MovieClipであること。
		 * 2. 対象のアニメーション属性が有効（真）であること。
		 */
		// 式をひとつまとめないでください。
		if (!Std.is(source, flash.display.MovieClip)) { return false; }
		
		var item:FlatomoItem = FlatomoTools.fetchItem(library, source);
		return item != null && item.animation;
	}
	
	private static function isAlliedToContainer(source:flash.display.DisplayObject):Bool {
		/*
		 * コンテナである条件は、
		 * 1. 対象は flash.display.DisplayObjectContainerであること。
		 */
		return Std.is(source, flash.display.DisplayObjectContainer);
	}
	
	
}

enum Meta {
	Animation(sections:Array<Section>);
	Container(children:Array<{ key:String, instanceName:String }>, layouts:Map < Int, Array<Layout> > , sections:Array<Section>);
	Image;
}

enum DisplayObjectKind {
	Animation;
	Container;
	Image;
}

