package flatomo;

typedef ContainerComponent = {
	name:InstanceName,
	path:ItemPath,
}

enum Structure {
	Container(children:Array<ContainerComponent>);
	Animation;
	PartsAnimation(parts:Array<ContainerComponent>);
	Image;
}
