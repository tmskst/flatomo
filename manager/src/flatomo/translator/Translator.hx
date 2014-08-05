package flatomo.translator;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Matrix;
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
	public static function create(library:FlatomoLibrary, classes:Array<Class<DisplayObject>>):{ images:Array<RawTexture>, postures:Map<ItemPath, Posture> } {
		var creator:Translator = new Translator(library);
		for (clazz in classes) {
			// 表示オブジェクトのインスタンスを生成して解析をする
			creator.translate(Type.createInstance(clazz, []), "F:" + Type.getClassName(clazz));
		}
		return { images: creator.images, postures: creator.postures };
	}
	
	private function new(library:FlatomoLibrary) {
		this.library = library;
		this.images = new Array<RawTexture>();
		this.postures = new Map<ItemPath, Posture>();
	}
	
	/* ライブラリは参照のみが許される。ライブラリが持つマップの変更は許されない。 */
	private var library:FlatomoLibrary;
	/* 表示オブジェクトをビットマップデータに転写したものの列挙。 */
	private var images:Array<RawTexture>;
	/* 任意の表示オブジェクトを再構築するために必要な情報。 */
	private var postures:Map<String, Posture>;
	
	
	/**
	 * 表示オブジェクトを解析して再構築に必要な情報（RawTexture, Meta）を取得します。
	 * @param	source
	 * @param	itemPath
	 */
	private function translate(source:DisplayObject, itemPath:String):Void {
		// itemPath = F:MainScene or Game/Foobar etc
		if (postures.exists(itemPath)) { return; }
		
		var type = source.fetchDisplayObjectType(itemPath, library);
		switch (type) {
			case DisplayObjectType.Animation : translateQuaAnimation(cast(source, MovieClip), itemPath);
			case DisplayObjectType.Container : translateQuaContainer(cast(source, MovieClip), itemPath);
			case DisplayObjectType.TextField : translateTextField(cast(source, TextField), itemPath);
			case DisplayObjectType.Image : translateQuaImage(source, itemPath);
		}
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Animationとして解析します。
	 * フレームは適切にカットされビットマップデータに転写されます。
	 * @param	source 対象の表示オブジェクト
	 * @param	itemPath ライブラリパス
	 */
	private function translateQuaAnimation(source:MovieClip, itemPath:ItemPath):Void {
		// ソースの描画領域を計算
		var unionBounds = Blitter.getUnionBound(source);
		
		// テクスチャを生成
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			var index = ("0000" + Std.string(frame)).substr(-4);
			var bounds = Blitter.getBounds(source);
			images.push( {
				index: frame,
				name: '${itemPath}${index}',
				image: Blitter.toBitmapData(source),
				frame: new Rectangle(unionBounds.x - bounds.x, unionBounds.y - bounds.y, unionBounds.width, unionBounds.height),
				unionBounds: unionBounds,
			});
		}
		var sections = library.extendedItems.get(itemPath).sections;
		postures.set(itemPath, Posture.Animation(sections));
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Containerとして解析します。
	 * コンテナは、表示オブジェクトコンテナで実際に目に見える表示オブジェクトではないため、
	 * このメソッド内でビットマップデータに転写することしません。
	 * コンテナ直下に配置された表示オブジェクト（直接の子）の配置情報を記録します。
	 * @param	source 対象の表示オブジェクト
	 */
	private function translateQuaContainer(source:MovieClip, itemPath:ItemPath):Void {
		var children = new Map<InstanceName, { path:String, layouts:Vector<Layout> }>();
		
		// 全フレームを走査して対象の直接の子の配置情報を収集する
		for (frame in 0...source.totalFrames) {
			source.gotoAndStop(frame + 1);
			
			// 現在のフレームの対象に追加されている直接の子を走査する
			for (childIndex in 0...source.numChildren) {
				var object = source.getChildAt(childIndex);
				var type = object.fetchDisplayObjectType(itemPath, library);
				if (!children.exists(object.name)) {
					var key = switch (type) {
						case DisplayObjectType.Animation : object.fetchItemPath(itemPath, library);
						case DisplayObjectType.Container : object.fetchItemPath(itemPath, library);
						case DisplayObjectType.TextField : '${itemPath}#${object.name}';
						case DisplayObjectType.Image	 : '${itemPath}#${object.name}';
					};
					children.set(object.name, {
						path	: key,
						layouts	: new Vector<Layout>(source.totalFrames + 1),
					});
					translate(object, key);
				}
				
				var transformationMatrix:Matrix = object.transform.matrix.clone();
				if (type.match(DisplayObjectType.Image)) {
					var bounds = Blitter.getBounds(object);
					transformationMatrix.translate(bounds.x, bounds.y);
				}
				
				var child = children.get(object.name);
				child.layouts.set(frame, { transform: transformationMatrix, depth: childIndex });
			}
		}
		
		var sections = library.extendedItems.get(itemPath).sections;
		postures.set(itemPath, Posture.Container(children, sections));
	}
	
	
	/**
	 * 表示オブジェクトをDisplayObjectType.Imageとして解析します
	 * @param	source 対象の表示オブジェクト
	 * @param	path 対象のライブラリパス
	 */
	private function translateQuaImage(source:DisplayObject, itemPath:ItemPath):Void {
		var bounds = Blitter.getBounds(source);
		images.push({ index: 0, name: itemPath, image: Blitter.toBitmapData(source, bounds), frame: null, unionBounds: bounds });
		postures.set(itemPath, Posture.Image);
	}
	
	/**
	 * 表示オブジェクトをDisplayObjectType.TextFieldとして解析します
	 * @param	source 対象の表示オブジェクト
	 * @param	itemPath 対象のライブラリパス
	 */
	private function translateTextField(source:TextField, itemPath:ItemPath):Void {
		postures.set(itemPath, Posture.TextField(Std.int(source.width), Std.int(source.height), source.text, source.getTextFormat()));
	}
	
}

@:allow(flatomo.Creator)
class DisplayObjectTools {
	
	/**
	 * 対象（Instance)をインスタンス化するために使用されたライブラリパスを取り出す
	 * @param	instance 対象
	 * @return 対象をインスタンス化するために使用されたライブラリパス
	 */
	public static function fetchItemPath(instance:flash.display.DisplayObject, parentItemPath:ItemPath, library:FlatomoLibrary):ItemPath {
		return library.itemPaths.get(parentItemPath + "#" + instance.name);
	}
	
	/** 表示オブジェクトが属するDisplayObjectTypeを返します。 */
	private static function fetchDisplayObjectType(source:DisplayObject, itemPath:ItemPath, library:FlatomoLibrary):DisplayObjectType {
		if (source.isAlliedToAnimation(itemPath, library)) {
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
	 * @param	itemPath 対象のライブラリパス
	 * @param	library ライブラリ
	 * @return 対象がアニメーションかどうか
	 */
	private static function isAlliedToAnimation(source:DisplayObject, itemPath:ItemPath, library:FlatomoLibrary):Bool {
		// 式をひとつまとめないでください。
		if (!Std.is(source, MovieClip)) { return false; }
		
		var item = library.extendedItems.get(itemPath);
		return item != null && item.displayObjectType.equals(FlatomoItem.DisplayObjectType.Animation);
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
