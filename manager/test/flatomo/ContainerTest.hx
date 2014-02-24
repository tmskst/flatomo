package flatomo;
import flatomo.Container;
import flatomo.Layout;
import massive.munit.Assert;

@:access(flatomo.Container)
class ContainerTest {
	
	public function new() { }
	
	@Test("生成直後は可視状態にある")
	public function afterConstruct_visible():Void {
		var sut = new Container([], new Map <Int, Array<Layout>>(), []);
		Assert.areEqual(true, sut.visible);
	}
	
}
