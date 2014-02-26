package flatomo;

enum Meta {
	Animation(sections:Array<Section>, pivotX:Float, pivotY:Float);
	Container(children:Array<{ key:String, instanceName:String }>, layouts:Map < Int, Array<Layout> > , sections:Array<Section>);
	Image;
}
