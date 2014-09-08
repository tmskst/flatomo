package flatomo.exporter;

import haxe.Serializer;
import jsfl.Element;
import jsfl.FLfile;
import jsfl.LayerType;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.SymbolItem;

class MarkerExporter {
	
	private static inline var EXTENSION_MARKERS = "mks";
	private static inline var PREFIX_MARKER_LAYER_NAME = "marker_";
	
	/**	
	 * マーカー情報をファイルに出力する。
	 * SWFプロファイルに設定されたディレクトリに `flaファイル名 + .mks` が出力される。
	 */
	public static function export(symbolItems:Array<SymbolItem>, outputPath:String):Void {
		/*
		var packedMarkers = new Map<ItemPath, Map<LayerName, Map<Int, Marker>>>();
		var library:Library = fl.getDocumentDOM().library;
		for (symbolItem in symbolItems) {
			library.editItem(symbolItem.name);
			
			var packedMarker = new Map<LayerName, Map<Int, Marker>>();
			var markerLayers = symbolItem.timeline.layers.filter(function (layer) {
				return	layer.layerType == LayerType.GUIDE &&
						StringTools.startsWith(layer.name, PREFIX_MARKER_LAYER_NAME);
			});
			for (markerLayer in markerLayers) {
				// マーカーが存在しないフレームもあり得る
				var markers = new Map<Int, Marker>();
				for (frameIndex in 0...markerLayer.frameCount) {
					var frame = markerLayer.frames[frameIndex];
					symbolItem.timeline.setSelectedFrames(frameIndex, frameIndex);
					for (element in frame.elements) {
						markers.set(frameIndex, fromElement(element));
					}
				}
				packedMarker.set(markerLayer.name, markers);
			}
			packedMarkers.set(symbolItem.linkageClassName, packedMarker);
		}
		FLfile.write(outputPath + "." + EXTENSION_MARKERS, Serializer.run(packedMarkers));
		*/
	}
	/*
	private static function fromElement(element:Element):Marker {
		return {
			x: element.x,
			y: element.y,
			width: element.width,
			height: element.height,
			rotation: element.rotation,
			scaleX: element.scaleX,
			scaleY: element.scaleY,
		};
	}
	*/
}
