package flatomo;
import flash.Vector.Vector;
import massive.munit.Assert;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;

@:access(flatomo.Animation)
class AnimationTest {

	public function new() { }
	
	@Test("生成直後のフレームは「1」")
	public function afterConstruct_currentFrame():Void {
		var sut = new Animation(createTextures(1), []); 
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("生成直後は可視状態にある")
	public function afterConstruct_visible():Void {
		var sut = new Animation(createTextures(1), []); 
		Assert.areEqual(true, sut.visible);
	}
	
	@Test("生成直後は再生中の状態にある")
	public function afterConstruct_isPlaying():Void {
		var sut = new Animation(createTextures(1), []); 
		Assert.areEqual(true, sut.isPlaying);
	}
	
	@Test("生成直後のテクスチャはテクスチャ集合の最初のもの")
	public function afterConstruct_texture():Void {
		var textures:Vector<Texture> = createTextures(3);
		var sut = new Animation(textures, [{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }]);
		Assert.areEqual(textures[0], sut.texture);
	}
	
	// flash.display.MovieClipの挙動と同じ
	@Test("advanceTimeの呼び出しとテクスチャの対応関係")
	public function afterAdvanceTime_texture():Void {
		var textures:Vector<Texture> = createTextures(3);
		var sut = new Animation(textures, []);
		// 生成直後のテクスチャは textures[0]（実際に描画されているかどうかは分からない）
		Assert.areEqual(textures[0], sut.texture);
		
		// Event.ENTER_FRAMEの送出に相当
		// 最初のadvanceTime呼び出しと同時1フレーム目が始まる
		sut.advanceTime(1.0);
		Assert.areEqual(textures[0], sut.texture);
		
		sut.advanceTime(1.0);
		Assert.areEqual(textures[1], sut.texture);
		
		sut.advanceTime(1.0);
		Assert.areEqual(textures[2], sut.texture);
	}
	
	@Test("SectionKind.Loop: 再生ヘッドはセクション内でループする")
	public function currentFrame_Loop():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }
		];
		var sut = new Animation(createTextures(3), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("SectionKind.Once: 再生ヘッドはセクションの最終フレームで停止する")
	public function currentFrame_Once():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 }
		];
		var sut = new Animation(createTextures(3), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
	}
	
	@Test("SectionKind.Pass: 再生ヘッドはセクションが終了しても進み続ける（次のセクションへと進む）")
	public function currentFrame_Pass():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Pass, begin: 4, end: 7 }
		];
		var sut = new Animation(createTextures(7), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("SectionKind.Standstill: 再生ヘッドはセクションの最初のフレームで停止する")
	public function currentFrame_Standstill():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Standstill, begin: 1, end: 3 }
		];
		var sut = new Animation(createTextures(3), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 再生ヘッドはセクションの最終フレームで指定したセクションへと移動する")
	public function currentFrame_Goto():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("c"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6},
			{ name: "c", kind: SectionKind.Goto("b"), begin: 7, end: 9}
		];
		var sut = new Animation(createTextures(9), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(7, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(8, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(9, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(6, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("SectionKind.Goto: 遷移先セクションが自身の場合はLoopと同等")
	public function currentFrame_Goto2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Goto("a"), begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Goto("a"), begin: 4, end: 6}
		];
		var sut = new Animation(createTextures(6), sections);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
	}
	
	private static function createTextures(length:Int):Vector<Texture> {
		var textures:Vector<Texture> = new Vector<Texture>(length, true);
		for (i in 0...length) {
			textures[i] = new ConcreteTexture(null, "bgra", 16, 16, false, false);
		}
		return textures;
	}
	
	
}
