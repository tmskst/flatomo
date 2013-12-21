package flatomo;

enum SectionKind {
	Loop;
	Once;
	Pass;
	Standstill;
	Goto(goto:Int);
}
