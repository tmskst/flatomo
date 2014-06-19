package flatomo;

import flatomo.display.Animation;
import flatomo.display.Playhead;
import massive.munit.Assert;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;

@:access(flatomo.display.Animation)
class AnimationTest {

	public function new() { }
	
	@Test("生成直後は可視状態にある")
	public function afterConstruct_visible():Void {
		var sut = new Animation(new haxe.ds.Vector<Layout>(0), createTextures(1)); 
		Assert.areEqual(true, sut.visible);
	}
	
	@Test("生成直後のテクスチャはテクスチャ集合の最初のもの")
	public function afterConstruct_texture():Void {
		var textures = createTextures(3);
		var sut = new Animation(new haxe.ds.Vector<Layout>(0), textures);
		Assert.areEqual(textures[0], sut.texture);
	}
	
	// flash.display.MovieClipの挙動と同じ
	// FIXME : 
	@Ignore
	@:allow(flatomo.Animation)
	@Test("advanceTimeの呼び出しとテクスチャの対応関係")
	public function afterAdvanceTime_texture():Void {
		var textures = createTextures(3);
		var playhead = new Playhead([]);
		var sut = new Animation(new haxe.ds.Vector<Layout>(0), textures);
		/*
		 * 生成直後のテクスチャは textures[0]
		 * このタイミングで実際に描画されているかどうかは分からない
		 * Event.ENTER_FRAMEと同じタイミングで表示リストに追加すれば、この段階でテクスチャは描画される。
		 * それ以降（非同期）のタイミングで表示リストに追加されたときはテクスチャ描画されない。
		 */
		Assert.areEqual(textures[0], sut.texture);
		
		/*
		 * アニメーションが表示リストに追加されて（ジャグラーに登録されて）以降、
		 * 初めてのEvent.ENTER_FRAME送出に相当する。
		 * この呼び出しを過ぎてからと同時に1フレーム目が始まる。
		 */
		playhead.advanceFrame(1);
		sut.draw(playhead.currentFrame);
		
		/*
		 * この段階では1フレーム目のテクスチャ描画されている。
		 */
		Assert.areEqual(textures[0], sut.texture);
		
		playhead.advanceFrame(1);
		sut.draw(playhead.currentFrame);
		Assert.areEqual(textures[1], sut.texture);
		
		playhead.advanceFrame(1);
		sut.draw(playhead.currentFrame);
		Assert.areEqual(textures[2], sut.texture);
	}
	
	private static function createTextures(size:Int):flash.Vector<Texture> {
		var textures = new flash.Vector<Texture>(size, true);
		for (i in 0...size) {
			textures[i] = new ConcreteTexture(null, "bgra", 16, 16, false, false);
		}
		return textures;
	}
	
}
