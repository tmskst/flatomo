package flatomo.util;

import flatomo.Section;
import flatomo.SectionKind;
import jsfl.Frame;
import jsfl.Layer;
import jsfl.Timeline;

class SectionCreator {
	
	/** 制御レイヤー名 */
	private static inline var CONTROL_LAYER_NAME:String = "label";
	
	/**
	 * ライムラインを元にセクション情報を抽出します
	 * @param	timeline 元となるタイムライン
	 * @return 生成されたセクション情報
	 */
	public static function fetchSections(timeline:Timeline):Array<Section> {
		// タイムライン中から制御レイヤーを抽出
		var layers:Array<Layer> = timeline.layers.filter(
			function(layer:Layer):Bool { return layer.name == CONTROL_LAYER_NAME; }
		);
		
		// 制御レイヤーが存在しない場合は自動的にセクションが生成される
		if (layers.length == 0) {
			return [{ name: "anonymous", kind: SectionKind.Once, begin: 1, end: timeline.frameCount }];
		}
		
		// 制御レイヤーが複数存在する場合はエラーを送出する
		if (layers.length != 1) {
			throw '複数のコントロールレイヤーが見つかりました';
		}
		
		var keyFrames:Array<Int> = new Array<Int>();
		
		// 制御レイヤーのキーフレームを探索して各キーフレームの開始フレームと終了フレームを抽出する
		var controlLayer:Layer = layers.shift();
		var frames:Array<Frame> = controlLayer.frames;
		for (i in 0...frames.length) {
			if (i == frames[i].startFrame) { keyFrames.push(i); }
		}
		keyFrames.push(controlLayer.frameCount);
		
		// セクションの生成
		var sections:Array<Section> = new Array<Section>();
		for (i in 0...keyFrames.length - 1) {
			var frame:Frame = frames[keyFrames[i]];
			// セクションの種類はExtendedItemと比較して差し替えられるので'Once'で良い
			sections.push({ name: frame.name, kind: SectionKind.Once, begin: keyFrames[i] + 1, end: keyFrames[i + 1] });
		}
		
		return sections;
	}
	
}
