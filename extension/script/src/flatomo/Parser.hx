package flatomo;

import flatomo.Structure;
import jsfl.Instance;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.Library;
import jsfl.SymbolItem;

using Lambda;
using flatomo.util.LibraryTools;
using flatomo.util.SymbolItemTools;
using flatomo.util.TimelineTools;

class Parser {
	
	public static function parse(library:Library):Map<String, Structure> {
		var parser = new Parser(library);
		return parser.structures;
	}
	
	/* --------------------------------------------------------------------- */
	
	/** 解析結果
	 * @key ライブラリアイテムのパス
	 * @value アイテムを再構築するために必要な情報
	 */
	private var structures:Map<String, Structure>;
	
	private function new(library:Library) {
		this.structures = new Map<String, Structure>();
		
		// 出力対象になり得るアイテムはシンボルアイテムのみだから
		// ライブラリのすべてのシンボルアイテムをルートに走査する
		for (symbolItem in library.symbolItems()) {
			var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
			// 出力対象ならば解析を開始する
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
		
		var children = new Array<ContainerComponent>();
		
		var instances:Array<Instance> = symbolItem.timeline.instances();
		for (i in 0...instances.length) {
			var instance:Instance = instances[i];
			translate(cast instance.libraryItem);
			children.push( {
				instanceName: symbolItem.name + '#' + i + '#' + instance.name,
				path: instance.libraryItem.name,
				layouts: [],
			});
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
		for (part in pap.parts) {
			structures.set(part.path, Structure.Image);
		}
		// FIXME END
		structures.set(symbolItem.name, Structure.PartsAnimation(pap.parts));
	}
	
	/** テクスチャとして解析する */
	private function translateQuaImage(item:Item):Void {
		trace('translateQuaImage : ${item.name}');
		structures.set(item.name, Structure.Image);
	}
	
}
