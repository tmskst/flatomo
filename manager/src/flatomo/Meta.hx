package flatomo;
import flash.text.TextFormat;

/** 表示オブジェクトを構築するために必要なメタデータ */
enum Meta {
	Animation(sections:Array<Section>, pivotX:Float, pivotY:Float);
	Container(children:Array<{ key:String, instanceName:String }>, layouts:Map <Int, Array<Layout>>, sections:Array<Section>);
	Image(pivotX:Float, pivotY:Float);
	TextField(width:Int, height:Int, text:String, textFormat:TextFormat);
}
