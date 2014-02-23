package flatomo;

enum Meta {
	Animation(sections:Array<Section>);
	Container(children:Array<{ key:String, instanceName:String }>, layouts:Map < Int, Array<Layout> > , sections:Array<Section>);
	Image;
}
