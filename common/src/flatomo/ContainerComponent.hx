package flatomo;

/**
 * コンテナ（パーツアニメーション）の構成要素
 * 再構築のときに必要な子に関する情報
 */
class ContainerComponent {
	/** インスタンス名 */
	public var instanceName(default, null):String;
	/** インスタンス化するために使用されるライブラリアイテムのパス */
	public var path(default, null):ItemPath;
	/** 配置情報 */
	public var layouts(default, null):Array<Layout>;
	
	public function new(instanceName:String, path:ItemPath, layouts:Array<Layout>) {
		this.instanceName = instanceName;
		this.path = path;
		this.layouts = layouts;
	}
	
}
