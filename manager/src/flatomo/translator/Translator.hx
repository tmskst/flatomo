package flatomo.translator;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.text.TextField;
import flatomo.InstanceName;
import haxe.ds.Vector;

using Lambda;
using flatomo.translator.Translator.DisplayObjectTools;

private enum DisplayObjectType {
	Animation;
	Container;
	Image;
	TextField;
}

@:allow(flatomo.Flatomo)
class Translator {
	
	/**
	 * 表示オブジェクトを解析してテクスチャとメタデータを生成します
	 * @param	library ライブラリ
	 * @param	classes 解析する（表示オブジェクトを親に持つ）クラスの列挙
	 */
	public static function create(library:FlatomoLibrary, classes:Array<Class<DisplayObject>>):{ images:Array<RawTexture>, meta:Map<String, Meta> } {
		var creator:Translator = new Translator(library);
		for (clazz in classes) {
			// 表示オブジェクトのインスタンスを生成して解析をする
			creator.translate(Type.createInstance(clazz, []), "F:" + Type.getClassName(clazz));
		}
		return { images: creator.images, meta: creator.meta };
	}
	
	private function new(library:FlatomoLibrary) {
		this.library = library;
		this.images = new Array<RawTexture>();
		this.meta = new Map<String, Meta>();
	}
	
	/* ライブラリは参照のみが許される。ライブラリが持つマップの変更は許されない。 */
	private var library:FlatomoLibrary;
	/* 表示オブジェクトをビットマップデータに転写したものの列挙。 */
	private var images:Array<RawTexture>;
	/* 任意の表示オブジェクトを再構築するために必要な情報。 */
	private var meta:Map<String, Meta>;
	
	
	/**
	 * 表示オブジェクトを解析して再構築に必要な情報（RawTexture, Meta）を取得します。
	 * @param	source
	 * @param	libraryPath
	 */
	private function translate(source:DisplayObject, libraryPath:String):Void {
		// libraryPath = F:MainScene or Game/Foobar etc
		if (meta.exists(libraryPath)) { return; }
		
		var type = source.fetchDisplayObjectType(libraryPath, library);
		switch (type) {
			case DisplayObjectType.Animation : translateQuaAnimation(cast(source, MovieClip), libraryPath);
			case DisplayObjectType.Container : translateQuaContainer(cast(source, MovieClip), libraryPath);
			case DisplayObjectType.TextField : translateTextField(cast(source, TextField), libraryPath);
			case DisplayObjectType.Image : translateQuaImage(source, libraryPath);
		}
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Animationとして解析します。
	 * フレームは適切にカットされビットマップデータに転写されます。
	 * @param	source 対象の表示オブジェクト
	 * @param	libraryPath ライブラリパス
	 */
	private function translateQuaAnimation(source:MovieClip, libraryPath:LibraryPath):Void {
		// ソースの描画領域を計算
		var unionBounds = Blitter.getUnionBound(source);
		
		// テクスチャを生成
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			var index = ("00000" + Std.string(frame)).substr(-5);
			var bounds = Blitter.getBounds(source);
			images.push( {
				name: '${libraryPath} ${index}',
				image: Blitter.toBitmapData(source),
				frame: new Rectangle(unionBounds.x - bounds.x, unionBounds.y - bounds.y, unionBounds.width, unionBounds.height)
			});
		}
		var sections = library.metadata.get(libraryPath).sections;
		meta.set(libraryPath, Meta.Animation(sections, -unionBounds.x, -unionBounds.y));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Containerとして解析します。
	 * コンテナは、表示オブジェクトコンテナで実際に目に見える表示オブジェクトではないため、
	 * このメソッド内でビットマップデータに転写することしません。
	 * コンテナ直下に配置された表示オブジェクト（直接の子）の配置情報を記録します。
	 * @param	source 対象の表示オブジェクト
	 */
	private function translateQuaContainer(source:MovieClip, libraryPath:LibraryPath):Void {
		var children = new Map<InstanceName, { path:String, layouts:Vector<Layout> }>();
		
		// 全フレームを走査して対象の直接の子の配置情報を収集する
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			
			// 現在のフレームの対象に追加されている直接の子を走査する
			for (childIndex in 0...source.numChildren) {
				var object = source.getChildAt(childIndex);
				if (!children.exists(object.name)) {
					var type = object.fetchDisplayObjectType(libraryPath, library);
					var key = switch (type) {
						case DisplayObjectType.Animation : object.fetchLibraryPath(libraryPath, library);
						case DisplayObjectType.Container : object.fetchLibraryPath(libraryPath, library);
						case DisplayObjectType.TextField : '${libraryPath}#${object.name}';
						case DisplayObjectType.Image	 : '${libraryPath}#${object.name}';
					};
					children.set(object.name, {
						path	: key,
						layouts	: new Vector<Layout>(source.totalFrames + 1),
					});
					translate(object, key);
				}
				
				var child = children.get(object.name);
				child.layouts.set(frame, {
					x: object.x,
					y: object.y,
					rotation: untyped { __global__["starling.utils.deg2rad"](object.rotation); } ,
					scaleX: object.scaleX,
					scaleY: object.scaleY,
				});
				
			}
		}
		
		var sections = library.metadata.get(libraryPath).sections;
		meta.set(libraryPath, Meta.Container(children, sections));
	}
	
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Imageとして解析します
	 * @param	source 対象の表示オブジェクト
	 * @param	path 対象のライブラリパス
	 */
	private function translateQuaImage(source:DisplayObject, libraryPath:LibraryPath):Void {
		var bounds = Blitter.getBounds(source);
		images.push({ name: libraryPath, image: Blitter.toBitmapData(source, bounds), frame: null });
		meta.set(libraryPath, Meta.Image(-bounds.x, -bounds.y));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.TextFieldとして解析します
	 * @param	source 対象の表示オブジェクト
	 * @param	libraryPath 対象のライブラリパス
	 */
	private function translateTextField(source:TextField, libraryPath:LibraryPath):Void {
		meta.set(libraryPath, Meta.TextField(Std.int(source.width), Std.int(source.height), source.text, source.getTextFormat()));
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
	
	/** 表示オブジェクトが属するDisplayObjectTypeを返します。 */
	private static function fetchDisplayObjectType(source:DisplayObject, libraryPath:LibraryPath, library:FlatomoLibrary):DisplayObjectType {
		if (source.isAlliedToAnimation(libraryPath, library)) {
			return DisplayObjectType.Animation;
		}
		if (source.isAlliedToContainer()) {
			return DisplayObjectType.Container;
		}
		if (source.isAlliedToTextField()) {
			return DisplayObjectType.TextField;
		}
		
		return DisplayObjectType.Image;
	}
	
	/**
	 * 表示オブジェクトがテキストフィールドかどうか
	 * @param	source 対象の表示オブジェクト
	 * @return 対象がテキストフィールドかどうか
	 */
	private static function isAlliedToTextField(source:DisplayObject):Bool {
		return Std.is(source, flash.text.TextField);
	}
	
	/**
	 * 表示オブジェクトがアニメーションかどうか
	 * 1. 対象がflash.display.MovieClipであること。
	 * 2. 対象のアニメーション属性が有効（真）であること。
	 * @param	source 対象の表示オブジェクト
	 * @param	libraryPath 対象のライブラリパス
	 * @param	library ライブラリ
	 * @return 対象がアニメーションかどうか
	 */
	private static function isAlliedToAnimation(source:DisplayObject, libraryPath:LibraryPath, library:FlatomoLibrary):Bool {
		// 式をひとつまとめないでください。
		if (!Std.is(source, MovieClip)) { return false; }
		
		var item = library.metadata.get(libraryPath);
		return item != null && item.animation;
	}
	
	/**
	 * 表示オブジェクトがコンテナがどうか
	 * @param	source 対象の表示オブジェクト
	 * @return 対象がコンテナかどうか
	 */
	private static function isAlliedToContainer(source:DisplayObject):Bool {
		return Std.is(source, DisplayObjectContainer);
	}
	
}
