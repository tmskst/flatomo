package flatomo;

enum Structure {
	Container(children:Array<Child>);
	Animation;
	PartsAnimation(parts:Array<Child>);
	Image;
}
