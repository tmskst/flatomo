package flatomo;

import flatomo.display.Container;
import flatomo.Layout;
import massive.munit.Assert;

@:access(flatomo.display.Container)
class ContainerTest {
	
	public function new() { }
	
	@Test("生成直後は可視状態にある")
	public function afterConstruct_visible():Void {
		var sut = new Container(new haxe.ds.Vector<Layout>(0), [], []);
		Assert.areEqual(true, sut.visible);
	}
	
}
