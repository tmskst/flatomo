package flatomo.extension;

import de.polygonal.ds.ListSet;
import de.polygonal.ds.Set;
import haxe.Unserializer;
import jsfl.ElementType;
import jsfl.Instance;
import jsfl.Lib.fl;
import jsfl.SymbolItem;
import jsfl.Text;


using jsfl.TimelineTools;

class Exporter {

	public static function main() {
		new Exporter();
	}
	
	public function new() {
		this.container = new ListSet<String>();
		
		var library = fl.getDocumentDOM().library;
		for (item in library.getSelectedItems()) {
			analyzeItem(cast item);
		}
		
		for (x in container) { fl.trace(x); }
	}
	
	private var container:Set<String>;
	
	private function analyzeItem(symbolItem:SymbolItem):Void {
		if (container.has(symbolItem.name)) { return; }
		
		symbolItem.timeline.scan_allElement(function (element) {
			// 深さ優先
			switch (element.elementType) {
				// エレメントがシェイプならキャプチャ
				case ElementType.SHAPE :
					fl.trace(symbolItem.name + "#" + element.name);
				 //エレメントがテキストならば
				case ElementType.TEXT : 
					var text:Text = cast element;
					switch (text.textType) {
						// StaticText のときだけキャプチャ
						case TextType.STATIC :
							fl.trace(symbolItem.name + "$" + element.name);
						// その他のテキストは再構築するのでキャプチャ不要
						case _ : 
					}
				// エレメントがインスタンスならば
				case ElementType.INSTANCE : 
					var instance:Instance = cast element;
					
					var extendedItem:FlatomoItem = if (instance.libraryItem.hasData("f_item")) {
						Unserializer.run(instance.libraryItem.getData("f_item"));
					} else {
						{ sections: [], animation: false };
					}
					if (extendedItem.animation) {
						fl.trace('quaAnimation : ${element.name}');
					} else {
						analyzeItem(cast cast(element, Instance).libraryItem);
					}
			}
		});
		
		container.set(symbolItem.name);
	}
	
}
