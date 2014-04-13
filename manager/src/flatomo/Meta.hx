package flatomo;

import flash.text.TextFormat;
import haxe.ds.Vector.Vector;

/** 表示オブジェクトを再構築するために必要な情報 */
enum Meta {
	Animation(sections:Array<Section>, pivotX:Float, pivotY:Float);
	/**
	 * @param layouts コンテナの直接の子の配置情報
	 */
	Container(children:Map<InstanceName, { path:String, layouts:Vector<Layout> }>, sections:Array<Section>);
	Image(pivotX:Float, pivotY:Float);
	TextField(width:Int, height:Int, text:String, textFormat:TextFormat);
}
