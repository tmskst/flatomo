package flatomo;

enum Structure {
	Container(children:Map<InstanceName, ItemPath>);
	Animation;
	PartsAnimation(parts:Map<InstanceName, ItemPath>);
	Image;
}
