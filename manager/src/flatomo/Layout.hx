package flatomo;

// TODO : 命名が不適切。Layout は x, yなどの表示オブジェクトのプロパティのみを持つべきです。

/** 表示オブジェクトの配置情報。 */
typedef Layout = {
	/** 表示オブジェクトのインスタンス名。 */
	var instanceName:InstanceName;
	var x:Float;
	var y:Float;
	var rotation:Float;
	var scaleX:Float;
	var scaleY:Float;
}
