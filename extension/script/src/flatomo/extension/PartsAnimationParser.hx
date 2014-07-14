package flatomo.extension;

import flatomo.FlatomoItem;
import jsfl.ElementType;
import jsfl.Frame;
import jsfl.Instance;
import jsfl.InstanceType;
import jsfl.Layer;
import jsfl.LayerType;
import jsfl.Matrix;
import jsfl.MatrixTools;
import jsfl.SymbolInstance;
import jsfl.SymbolItem;
import jsfl.SymbolType;
import jsfl.Timeline;
import jsfl.TweenType;
import jsfl.Lib.fl;

using Lambda;
using flatomo.extension.util.ItemTools;

class PartsAnimationParser {
	
	public static function parse(rootSymbolItem:SymbolItem):{ parts:Array<Array<{ name:String, matrix:Matrix, id:Int, depth:Int }>>, numTextures:Map<String, Int> } {
		var parts = new Array<Array<{ name:String, matrix:Matrix, id:Int, depth:Int }>>();
		for (frameIndex in 0...rootSymbolItem.timeline.frameCount) {
			parts.push(new PartsAnimationParser(rootSymbolItem, frameIndex).parts);
		}
		
		var numTextures = new Map<String, Int>();
		for (frame in parts) {
			var numTexturesPerFrame = new Map<String, Int>();
			for (element in frame) {
				numTexturesPerFrame.set(element.name, if (!numTexturesPerFrame.exists(element.name)) 1 else numTexturesPerFrame.get(element.name) + 1);
				element.id = numTexturesPerFrame.get(element.name) - 1; 
			}
			
			for (key in numTexturesPerFrame.keys()) {
				if (!numTextures.exists(key)) {
					numTextures.set(key, numTexturesPerFrame.get(key));
				} else {
					numTextures.set(key, Std.int(Math.max(numTextures.get(key), numTexturesPerFrame.get(key))));
				}
			}
		}
		
		return { parts: parts, numTextures: numTextures };
	}
	
	private var parts:Array<{ name:String, matrix:Matrix, id:Int, depth:Int }>;
	private var depth:Int = 0;
	private function new(rootSymbolItem:SymbolItem, frameIndex:Int) {
		//trace("###" + rootSymbolItem.name + ", " + frameIndex);
		parts = new Array<{ name:String, matrix:Matrix, id:Int, depth:Int }>();
		analyze(rootSymbolItem, frameIndex, new Array<Matrix>());
	}
	
	private function analyze(symbolItem:SymbolItem, frameIndex:Int, stack:Array<Matrix>):Void {
		var timeline:Timeline = symbolItem.timeline;
		//trace(symbolItem.name + ", " + frameIndex);
		
		for (layerIndex in 0...timeline.layerCount) {
			var layer:Layer = timeline.layers[(timeline.layerCount - 1) - layerIndex];
			if (layer.layerType.equals(LayerType.GUIDE) || layer.layerType.equals(LayerType.GUIDED)) { continue; }
			
			var frame:Frame = layer.frames[frameIndex];
			if (frame == null) { continue; }
			
			// Tween.geometricTransform
			var geometricTransform:Matrix = if (frame.tweenType == TweenType.NONE) {
				MatrixTools.createIdentityMatrix();
			} else {
				frame.tweenObj.getGeometricTransform(frameIndex - frame.tweenObj.startFrame);
			}
			
			for (element in frame.elements) {
				if (!element.elementType.equals(ElementType.INSTANCE)) { continue; }
				var instance:Instance = cast element;
				stack.push(MatrixTools.concatMatrix(instance.matrix, geometricTransform));
				
				if (instance.instanceType != InstanceType.SYMBOL) { continue; }
				
				var librarySymbolItem:SymbolItem = cast instance.libraryItem;
				var flatomoItem:FlatomoItem = librarySymbolItem.getFlatomoItem();
				
				if (flatomoItem.primitiveItem) {
					// fold
					var result:Matrix = MatrixTools.createIdentityMatrix();
					for (matrix in stack) {
						result = MatrixTools.concatMatrix(matrix, result);
					}
					//trace(instance.libraryItem.name + ", " + depth);
					parts.push( { name: instance.libraryItem.name, matrix: result, id: -1, depth: depth++ } );
					stack.pop();
				} else {
					var symbolInstance:SymbolInstance = cast instance;
					var firstFrame:Int = symbolInstance.firstFrame;
					var frameCount:Int = cast(symbolInstance.libraryItem, SymbolItem).timeline.frameCount;
					
					var symbolFrame:Int = switch (symbolInstance.symbolType) {
						case SymbolType.MOVIE_CLIP : 0;
						case SymbolType.GRAPHIC :
							switch (symbolInstance.loop) {
								case LoopType.LOOP :
									(frameIndex + firstFrame - frame.startFrame) % frameCount;
								case LoopType.PLAY_ONCE :
									Math.ceil(Math.min(frameIndex + firstFrame - frame.startFrame, frameCount - 1));
								case LoopType.SINGLE_FRAME :
									firstFrame;
							};
						case SymbolType.BUTTON :
							throw 'Ignored : Button Symbol';
					}
					//trace("SYMBOL FRAME : " + symbolFrame);
					analyze(cast symbolInstance.libraryItem, symbolFrame, stack);
				}
				
			}
		}
		stack.pop();
	}
	
}
