package flatomo.extension;

import jsfl.ElementType;
import jsfl.Frame;
import jsfl.Instance;
import jsfl.InstanceType;
import jsfl.Item;
import jsfl.LayerType;
import jsfl.Matrix;
import jsfl.MatrixTools;
import jsfl.SymbolInstance;
import jsfl.SymbolItem;
import jsfl.SymbolType;
import jsfl.Tween;
import jsfl.TweenType;

using Lambda;
using jsfl.MatrixTools;
using flatomo.extension.util.ItemTools;

class PartsAnimationParser {
	
	/*
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
	*/
	
	public static function parse(rootSymbolItem:SymbolItem):{ x:Array<{ name:String, matrixes:Array<Matrix> }>, y:Array<Item> } {
		var parser:PartsAnimationParser = new PartsAnimationParser(rootSymbolItem);
		var result = new Array<{ name:String, matrixes:Array<Matrix> }>();
		
		/*
		 *	matrixes : {
		 *		Symbol0 => [
		 *			[
		 * 				{ a : 1, b : 0, c : 0, d : 1, tx :   0, ty :   0 },
		 * 				{ a : 1, b : 0, c : 0, d : 1, tx : 100, ty :   0 }
		 * 			],
		 *			[
		 * 				{ a : 1, b : 0, c : 0, d : 1, tx : 100, ty : 100 },
		 * 				{ a : 1, b : 0, c : 0, d : 1, tx : 200, ty : 200 }
		 *			]
		 *		]
		 *	}
		 */
		for (name in parser.matrixes.keys()) {
			//trace(name);
			var timeline:Array<Array<Matrix>> = parser.matrixes.get(name);
			while (timeline.exists(function (frame) { return frame.length != 0; } )) {
				var matrixes:Array<Matrix> = [for (i in 0...timeline.length) null];
				for (frameIndex in 0...timeline.length) {
					var frame:Array<Matrix> = timeline[frameIndex];
					if (!frame.empty()) {
						matrixes[frameIndex] = frame.pop();
					}
				}
				//trace(matrixes);
				result.push({ name: name, matrixes: matrixes });
			}
		}
		return { x: result, y: parser.items };
	}
	
	public function new(rootSymbolItem:SymbolItem):Void {
		this.currentFrame = 0;
		this.frameCount = rootSymbolItem.timeline.frameCount;
		this.matrixes = new Map<String, Array<Array<Matrix>>>();
		this.items = new Array<Item>();
		
		for (frameIndex in 0...frameCount) {
			currentFrame = frameIndex;
			trace("-------NEXT FRAME---------------------------");
			analyze(rootSymbolItem, frameIndex, new Array<Matrix>());
		}
	}
	
	private var currentFrame:Int;
	private var frameCount:Int;
	private var matrixes:Map<String, Array<Array<Matrix>>>;
	private var items:Array<Item>;
	
	private function addMatrix(name:String, matrix:Matrix, frameIndex:Int, item:Item):Void {
		if (!matrixes.exists(name)) {
			items.push(item);
			matrixes.set(name, [for (i in 0...frameCount) []]);
		}
		trace(frameIndex + ", " + name);
		var container:Array<Array<Matrix>> = matrixes.get(name);
		container[frameIndex].push(matrix);
	}
	
	private function analyze(symbolItem:SymbolItem, frameIndex:Int, stack:Array<Matrix>):Void {
		//{ 走査するフレーム（フレームが存在する通常レイヤー）
		var frames:Array<Frame> = symbolItem.timeline.layers
			.filter(function (layer) { return layer.layerType.equals(LayerType.NORMAL); })
			.map   (function (layer) { return layer.frames[frameIndex]; } )
			.filter(function (frame) { return frame != null; } );
		//} 
		frames.reverse();
		
		for (frame in frames) {
			for (element in frame.elements) {
				trace(frameIndex + ", " + element.layer.name + ", " + element.name);
			}
			
			
			var geometricTransform:Matrix = switch (frame.tweenType) {
				case TweenType.NONE, TweenType.SHAPE :
					MatrixTools.createIdentityMatrix();
				case TweenType.MOTION, TweenType.MOTION_OBJECT :
					var tween:Tween = frame.tweenObj;
					tween.getGeometricTransform(frameIndex - tween.startFrame);
			};
			
			// 走査するインスタンス（フレームに配置されたエレメントのうちインスタンスだけ）
			var instances:Array<Instance> = untyped frame.elements
				.filter(function (element) { return element.elementType.equals(ElementType.INSTANCE); } );
			
			for (instance in instances) {
				stack.push(MatrixTools.concatMatrix(instance.matrix, geometricTransform));
				
				// パーツアニメーションの基本単位（プリミティブインスタンス）
				// 1. インスタンスがビットマップならば強制的にパーツアニメーションの基本単位とみなす
				// 2. 拡張アイテムについて`プリミティブ属性`が有効ならパーツアニメーションの基本単位とする
				var primitive:Bool = 
					instance.instanceType == InstanceType.BITMAP ||
					instance.instanceType == InstanceType.SYMBOL && ItemTools.getFlatomoItem(untyped instance.libraryItem).primitiveItem;
				
				// インスタンスがパーツアニメーションの基本単位
				if (primitive) {
					var result:Matrix = stack
						.fold(function (matrix1, matrix2) { return matrix1.concatMatrix(matrix2); }, MatrixTools.createIdentityMatrix());
					
					addMatrix(instance.libraryItem.name, result, currentFrame, instance.libraryItem);
					stack.pop();
				}
				// パーツアニメーションの基本単位ではないシンボルインスタンス（インスタンスが子を持っている）
				else if (instance.instanceType == InstanceType.SYMBOL) {
					var symbolInstance:SymbolInstance = cast instance;
					if (symbolInstance.symbolType.equals(SymbolType.BUTTON)) { continue; }
					
					var firstFrame:Int = symbolInstance.firstFrame;
					var frameCount:Int = cast(symbolInstance.libraryItem, SymbolItem).timeline.frameCount;
					
					var symbolFrameIndex:Int = switch (symbolInstance.symbolType) {
						case SymbolType.MOVIE_CLIP : 0;
						case SymbolType.GRAPHIC :
							switch (symbolInstance.loop) {
								case LoopType.LOOP			: (frameIndex + firstFrame - frame.startFrame) % frameCount;
								case LoopType.PLAY_ONCE 	: Math.ceil(Math.min(frameIndex + firstFrame - frame.startFrame, frameCount - 1));
								case LoopType.SINGLE_FRAME	: firstFrame;
							};
						case SymbolType.BUTTON :
							throw 'Ignored : Button Symbol';
					}
					
					analyze(cast symbolInstance.libraryItem, symbolFrameIndex, stack);
				}
			}
		}
		stack.pop();
	}
	
}
