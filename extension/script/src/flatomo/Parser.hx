package flatomo;

import flatomo.Structure;
import jsfl.Instance;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.Library;
import jsfl.SymbolItem;

using Lambda;
using flatomo.Parser;
using jsfl.util.TimelineUtil;
using jsfl.util.LibraryUtil;
using flatomo.util.SymbolItemTools;
using flatomo.util.TimelineTools;

class Parser {
	
	@:noUsing
	public static function parse(library:Library):Map<String, Structure> {
		var parser = new Parser(library);
		return parser.structures;
	}
	
	/* --------------------------------------------------------------------- */
	
	private static function uniq<T>(xs:Array<T>):Iterable<T> {
		return [for (i in 0...xs.length) if (xs.indexOf(xs[i], i + 1) == -1) xs[i]];
	}
	
	private static function flatten(xs:Iterable<Dynamic>):Array<Dynamic> {
		var rs = [];
		var f:Iterable<Dynamic> -> Void = null;
		f = function (es) {
			for (e in es) {
				if (Std.is(e, Array)) f(cast e) else rs.push(e);
			}
		};
		f(xs);
		return rs;
	}
	
	private static function findi<T>(it:Iterable<T>, f:T -> Bool):Null<Int> {
		var i:Int = 0;
		
		for (v in it) {
			if (f(v)) return i;
			i++;
		}
		return null;
	}
	
	private static function fromInstance(instance:Null<Instance>, depth:Int):Layout {
		return if (instance == null) null else { depth: depth, transform: instance.matrix };
	};
	
	/* --------------------------------------------------------------------- */
	
	/** 解析結果
	 * @key ライブラリアイテムのパス
	 * @value アイテムを再構築するために必要な情報
	 */
	private var structures:Map<String, Structure>;
	
	/**
	 * 解析開始
	 * ライブラリを元に`structures:Map<String, Structure>`を作成する
	 * @param	library
	 */
	private function new(library:Library) {
		this.structures = new Map<String, Structure>();
		
		// 出力対象になり得るアイテムはシンボルアイテムのみだから
		// ライブラリのすべてのシンボルアイテムをルートに走査する
		for (symbolItem in library.symbolItems()) {
			var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
			// 出力対象ならば解析を開始する
			// リンケージ設定が有効でかつパネルで出力対象としたものが対象
			// TODO : リンケージ設定は必要ないかもしれない
			if (symbolItem.linkageExportForAS && extendedItem.linkageExportForFlatomo) {
				translate(symbolItem);
			}
		}
		trace(structures);
	}
	
	// 解析する対象はコンテナの子も含むので必ずしもシンボルアイテムという訳ではない
	private function translate(item:Item):Void {
		// 解析済みの場合はすぐに中止する
		if (structures.exists(item.name)) { trace('変換済み : ${item.name}'); return; }
		
		switch (item.itemType) {
			// 対象が MovieClip, Graphics ならば出力対象になり得る
			case ItemType.MOVIE_CLIP, ItemType.GRAPHIC :
				var symbolItem:SymbolItem = cast item;
				var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
				
				// 出力対象（子にアクセス可能かどうかは無視する）
				if (extendedItem.linkageExportForFlatomo) {
					switch (extendedItem.exportClassKind) {
						case ExportClassKind.Container      : translateQuaContainer(symbolItem);
						case ExportClassKind.Animation      : translateQuaAnimation(symbolItem);
						case ExportClassKind.PartsAnimation : translateQuaPartsAnimation(symbolItem);
					}
				}
				// 出力対象ではない
				else {
					// 子にアクセス可能（コンテナとする）
					if (extendedItem.areChildrenAccessible) {
						trace('Translate (areChildrenAccessible): ${symbolItem.name}');
						translateQuaContainer(symbolItem);
					}
					// 子にアクセス不可能（アイテムをテクスチャとする）
					else {
						trace('Translate (areNotChildrenAccessible): ${symbolItem.name}');
						translateQuaImage(symbolItem);
					}
				}
			// Bitmap は出力対象になり得ない
			case ItemType.BITMAP :
				translateQuaImage(item);
		}
	}
	
	/** コンテナとして解析する */
	private function translateQuaContainer(symbolItem:SymbolItem):Void {
		trace('translateQuaContainer : ${symbolItem.name}');
		
		var totalFrames:Int = symbolItem.timeline.frameCount;
		
		var getInstances:Int -> Array<Instance> = function (frameIndex) {
			return untyped symbolItem.timeline.layers
				.filter (function (layer) return layer.layerType.equals(NORMAL))
				.map    (function (layer) return layer.frames[frameIndex])
				.filter (function (frame) return frame != null)
				.map    (function (frame) return frame.elements)
				.flatten();
		};
		
		var children = new Array<ContainerComponent>();
		
		{ // ONYMOUS INSTANCES
			var onymousInstanceNames:Iterable<String> = symbolItem.timeline.instances()
				.filter(function (i) return i.name != "")
				.map   (function (i) return i.name)
				.uniq  ();
			
			for (onymousInstanceName in onymousInstanceNames) {
				
				var itemPath:String = null;
				var layouts = new Array<Layout>();
				
				for (frameIndex in 0...totalFrames) {
					
					var instances:Array<Instance> = getInstances(frameIndex);
					
					var onymousInstanceIndex:Null<Int> = instances
						.findi(function (instance) return instance.name == onymousInstanceName);
					
					if (onymousInstanceIndex != null) {
						var instance:Instance = instances[onymousInstanceIndex];
						layouts.push(fromInstance(instance, onymousInstanceIndex));
						itemPath = instance.libraryItem.name;
					} else {
						layouts.push(null);
					}
				}
				
				children.push( { instanceName: onymousInstanceName, path: itemPath, layouts: layouts } );
			}
		}
		
		{ // ANONYMOUS INSTANCES
			var isAnonymousInstance:Instance -> Bool = function (instance) {
				return instance.name == "";
			};
			
			var layouts = new Map<String, Array<Array<Layout>>>();
			var addLayout:String -> Layout -> Int -> Void = function (name, layout, frameIndex) {
				if (!layouts.exists(name)) {
					layouts.set(name, [for (i in 0...totalFrames) []]);
				}
				layouts.get(name)[frameIndex].push(layout);
			}
			
			for (frameIndex in 0...totalFrames) {
				var instances:Array<Instance> = getInstances(frameIndex);
				for (instanceDepth in 0...instances.length) {
					var instance:Instance = cast instances[instanceDepth];
					if (isAnonymousInstance(instance)) {
						addLayout(instance.libraryItem.name, { depth: instance.depth, transform: instance.matrix }, frameIndex);
					}
				}
			}
			
			for (name in layouts.keys()) {
				var line:Array<Array<Layout>> = layouts.get(name);
				while (line.exists(function (frame) return frame.length != 0)) {
					var ls:Array<Layout> = [for (i in 0...totalFrames) null];
					for (frameIndex in 0...totalFrames) {
						var frame:Array<Layout> = line[frameIndex];
						if (!frame.empty()) {
							ls[frameIndex] = frame.pop();
						}
					}
					children.push( { instanceName: "X", path: name, layouts: ls } );
				}
			}
			
		}
		
		for (child in children) {
			translate(jsfl.Lib.fl.getDocumentDOM().library.getItem(child.path));
		}
		
		structures.set(symbolItem.name, Structure.Container(children));
	}
	
	/** アニメーションとして解析する */
	private function translateQuaAnimation(symbolItem:SymbolItem):Void {
		trace('translateQuaAnimation : ${symbolItem.name}');
		structures.set(symbolItem.name, Structure.Animation);
	}
	
	/** パーツアニメーションとして解析する */
	private function translateQuaPartsAnimation(symbolItem:SymbolItem):Void {
		var pap = PartsAnimationParser.parse(symbolItem);
		// FIXME BEGIN
		for (part in pap) {
			structures.set(part.path, Structure.Image({ a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0 }));
		}
		// FIXME END
		structures.set(symbolItem.name, Structure.PartsAnimation(pap));
	}
	
	/** テクスチャとして解析する */
	private function translateQuaImage(item:Item):Void {
		trace('translateQuaImage : ${item.name}');
		structures.set(item.name, Structure.Image({ a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0 }));
	}
	
}
