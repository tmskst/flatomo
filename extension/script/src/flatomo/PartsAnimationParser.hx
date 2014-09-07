package flatomo;

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
using flatomo.util.ItemTools;

class PartsAnimationParser {
	
	public static function parse(rootSymbolItem:SymbolItem):{ parts:Array<{ path:String, layouts:Array<Layout> }>, items:Array<Item> } {
		var parser:PartsAnimationParser = new PartsAnimationParser(rootSymbolItem);
		var result = new Array<{ path:String, layouts:Array<Layout> }>();
		
		for (name in parser.matrixes.keys()) {
			var timeline:Array<Array<Layout>> = parser.matrixes.get(name);
			while (timeline.exists(function (frame) { return frame.length != 0; } )) {
				var matrixes:Array<Layout> = [for (i in 0...timeline.length) null];
				for (frameIndex in 0...timeline.length) {
					var frame:Array<Layout> = timeline[frameIndex];
					if (!frame.empty()) {
						matrixes[frameIndex] = frame.pop();
					}
				}
				result.push({ path: name, layouts: matrixes });
			}
		}
		return { parts: result, items: parser.items };
	}
	
	public function new(rootSymbolItem:SymbolItem):Void {
		this.currentFrame = 0;
		this.frameCount = rootSymbolItem.timeline.frameCount;
		this.matrixes = new Map<String, Array<Array<Layout>>>();
		this.items = new Array<Item>();
		
		for (frameIndex in 0...frameCount) {
			currentFrame = frameIndex;
			childIndex = 0;
			analyze(rootSymbolItem, frameIndex, new Array<Matrix>());
		}
	}
	
	private var childIndex:Int;
	private var currentFrame:Int;
	private var frameCount:Int;
	private var matrixes:Map<String, Array<Array<Layout>>>;
	private var items:Array<Item>;
	
	private function addMatrix(name:String, matrix:Matrix, frameIndex:Int, item:Item):Void {
		if (!matrixes.exists(name)) {
			items.push(item);
			matrixes.set(name, [for (i in 0...frameCount) []]);
		}
		var container:Array<Array<Layout>> = matrixes.get(name);
		container[frameIndex].push({ transform: matrix, depth:childIndex++ });
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
					instance.instanceType == InstanceType.SYMBOL/* && ItemTools.getExtendedItem(untyped instance.libraryItem).primitiveItem*/;
				
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
