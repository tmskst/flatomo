package flatomo;

/**
 * 拡張された'jsfl.Item'
 * 元のItemに保存される
 * @see flatomo.util.ItemTools
 */
typedef ExtendedItem = {
	/**
	 * 対象のシンボルがFlatomoによって出力されるかどうか
	 * ここでいう出力対象とは abstract定義が生成されること
	 * すなわち、GpuOperator.createを用いて表示オブジェクトを作成することができるということ
	 */
	linkageExportForFlatomo:Bool,
	/** 子にアクセス可能かどうか */
	areChildrenAccessible:Bool,
	/** 対象のシンボルの出力形式（コンテナ、アニメーション、パーツアニメーションのいずれか） */
	exportClassKind:ExportClassKind,
	/** 対象のシンボルのタイムラインに対応するセクション情報 */
	sections:Array<Section>,
}
