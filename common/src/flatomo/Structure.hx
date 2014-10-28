package flatomo;

/**
 * コンテナ（パーツアニメーション）の構成要素
 * 再構築のときに必要な子に関する情報
 */
typedef ContainerComponent = {
	/** インスタンス名 */
	instanceName:String,
	/** インスタンス化するために使用されるライブラリアイテムのパス */
	path:ItemPath,
	/** 配置情報 */
	layouts:Array<Layout>,
}

/** 出力対象のアイテムを再構築するために必要な情報 */
enum Structure {
	/** 対象は'flatomo.display.Container'として再構築される */
	Container(children:Array<ContainerComponent>);
	/** 対象は'flatomo.display.Animation'として再構築される */
	Animation(totalFrames:Int, unionBounds:Bounds);
	/** 対象は'flatomo.display.Container'として再構築される */
	PartsAnimation(parts:Array<ContainerComponent>);
	/** 対象は'flatomo.display.FlatomoImage'として再構築される */
	Image(transform:GeometricTransform, bounds:Bounds);
}
