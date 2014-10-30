package flatomo;

import flatomo.Structure;
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
using flatomo.util.SymbolItemTools;

class PartsAnimationParser {
	
	private static var i:Int = 0;
	
	public static function parse(rootSymbolItem:SymbolItem):Array<ContainerComponent> {
		var parser:PartsAnimationParser = new PartsAnimationParser(rootSymbolItem);
		var result = new Array<ContainerComponent>();
		
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
				result.push({ instanceName: 'anonymous' + Std.string(i++), path: name, layouts: matrixes });
			}
		}
		return result;
	}
	
	private function new(rootSymbolItem:SymbolItem):Void {
		this.currentFrame = 0;
		this.frameCount = rootSymbolItem.timeline.frameCount;
		this.matrixes = new Map<String, Array<Array<Layout>>>();
		
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
	
	private function addMatrix(name:String, matrix:Matrix, frameIndex:Int):Void {
		if (!matrixes.exists(name)) {
			matrixes.set(name, [for (i in 0...frameCount) []]);
		}
		var container:Array<Array<Layout>> = matrixes.get(name);
		container[frameIndex].push({ transform: matrix, depth:childIndex++ });
	}
	
	private function analyze(symbolItem:SymbolItem, frameIndex:Int, stack:Array<Matrix>):Void {
		//{ 解析対象のフレーム（通常レイヤーでかつエレメントが配置されているフレーム）
		var frames:Array<Frame> = symbolItem.timeline.layers
			.filter(function (layer) { return layer.layerType.equals(LayerType.NORMAL); })
			.map   (function (layer) { return layer.frames[frameIndex]; } )
			.filter(function (frame) { return frame != null; } );
		//} 
		frames.reverse();
		
		for (frame in frames) {
			// フレームに指定された幾何変換行列（トゥイーンによる変化）
			var geometricTransform:Matrix = switch (frame.tweenType) {
				// トゥイーンが存在しないかシェイプトゥイーンならば単位行列
				case TweenType.NONE, TweenType.SHAPE :
					MatrixTools.createIdentityMatrix();
				// モーショントゥイーンかクラシックトゥイーンならばトゥイーンから変換行列を取得
				case TweenType.MOTION, TweenType.MOTION_OBJECT :
					var tween:Tween = frame.tweenObj;
					tween.getGeometricTransform(frameIndex - tween.startFrame);
			};
			
			// 解析対象のインスタンス（フレームに配置されたエレメントのうちインスタンスだけ）
			var instances:Array<Instance> = untyped frame.elements
				.filter(function (element) { return element.elementType.equals(ElementType.INSTANCE); } );
			
			// タイムラインの'frameIndex'フレーム目に配置されているインスタンスすべてについて
			for (instance in instances) {
				// インスタンスの変換行列とフレームに指定された変換行列を合成
				stack.push(MatrixTools.concatMatrix(instance.matrix, geometricTransform));
				
				// パーツアニメーションの基本単位（プリミティブインスタンス）
				// インスタンスがビットマップならばパーツアニメーションの最小単位する
				var primitive:Bool = instance.instanceType == InstanceType.BITMAP;				
				
				// インスタンスがパーツアニメーションの基本単位
				if (primitive) {
					// 変換行列をすべて合成
					var result:Matrix = stack.fold(function (matrix1, matrix2) { return matrix1.concatMatrix(matrix2); }, MatrixTools.createIdentityMatrix());
					
					addMatrix(instance.libraryItem.name, result, currentFrame);
					stack.pop();
				}
				
				// パーツアニメーションの基本単位ではないシンボルインスタンス（インスタンスが子を持っている）
				else if (instance.instanceType == InstanceType.SYMBOL) {
					var symbolInstance:SymbolInstance = cast instance;
					// 開始フレーム
					var firstFrame:Int = symbolInstance.firstFrame;
					// 現在のタイムラインの総フレーム数
					var frameCount:Int = cast(symbolInstance.libraryItem, SymbolItem).timeline.frameCount;
					
					var symbolFrameIndex:Int = switch (symbolInstance.symbolType) {
						// ムービークリップは配置される位置に関係ない
						case SymbolType.MOVIE_CLIP : 0;
						// グラフィックは配置されるフレームが何番目かで描画するフレームが変化する
						case SymbolType.GRAPHIC :
							switch (symbolInstance.loop) {
								case LoopType.LOOP			: (frameIndex + firstFrame - frame.startFrame) % frameCount;
								case LoopType.PLAY_ONCE 	: Math.ceil(Math.min(frameIndex + firstFrame - frame.startFrame, frameCount - 1));
								case LoopType.SINGLE_FRAME	: firstFrame;
							};
						// パーツアニメーションはボタンを無視する
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
