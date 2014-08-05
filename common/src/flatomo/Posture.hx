package flatomo;

#if flash
import flash.text.TextFormat;
#end

/** 表示オブジェクトを再構築するために必要な情報 */
enum Posture {
	Animation(sections:Array<Section>);
	Container(children:Map<InstanceName, { path:String, layouts:Array<Layout> }>, sections:Array<Section>);
	#if flash
	Image;
	TextField(width:Int, height:Int, text:String, textFormat:TextFormat);
	#end
}
