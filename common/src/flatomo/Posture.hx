package flatomo;

#if flash
import flash.text.TextFormat;
#end
import haxe.ds.Vector.Vector;

/** 表示オブジェクトを再構築するために必要な情報 */
enum Posture {
	Animation(sections:Array<Section>);
	#if flash
	/**
	 * @param layouts コンテナの直接の子の配置情報
	 */
	Container(children:Map<InstanceName, { path:String, layouts:Vector<Layout> }>, sections:Array<Section>);
	Image;
	TextField(width:Int, height:Int, text:String, textFormat:TextFormat);
	#end
}
