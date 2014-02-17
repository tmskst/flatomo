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
		sut.advanceTime(1.0);
		
		/*
		 * この段階では1フレーム目のテクスチャ描画されている。
		 */
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
	
	@Test("SectionKind.Pass: 最終フレームにはGoto(1)が挿入される")
	public function currentFrame_Pass2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 3 }
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
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
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
	
	@Test("生成直後にplayを呼び出したときのフレームの遷移は呼び出さなかったときの遷移に等しい")
	public function afterConstruct_play():Void {
		var sut = new Animation(createTextures(3), []);
		Assert.areEqual(1, sut.currentFrame);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
	}
	
	@Test("生成直後にstopを呼び出すと再生ヘッドは移動しない")
	public function afterConstruct_apply_stop():Void {
		var sut = new Animation(createTextures(3), [{ name: "a", kind: SectionKind.Loop, begin: 1, end: 3 }]); 
		sut.stop();
		sut.advanceTime(1.0);
		sut.advanceTime(1.0);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
	}
	
	@Test("playを呼び出すと再生ヘッドは移動し始める")
	public function play_currentFrame():Void {
		var sut = new Animation(createTextures(6), [{ name: "a", kind: SectionKind.Loop, begin: 1, end: 6 }]); 
		sut.advanceTime(1.0); // 1
		sut.advanceTime(1.0); // 2
		sut.advanceTime(1.0); // 3
		Assert.areEqual(3, sut.currentFrame);
		
		sut.stop();
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(3, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("制御コードで停止した後にplayを呼び出すと再生ヘッドは移動し始める")
	public function play_currentFrame2():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Animation(createTextures(6), sections);
		sut.advanceTime(1.0); // 1
		sut.advanceTime(1.0); // 1
		sut.advanceTime(1.0); // 2
		sut.advanceTime(1.0); // 3
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		// 制御コード Stopにより再生ヘッドは停止した
		Assert.areEqual(3, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(3, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("生成直後にgotoGlobalAndPlayを呼び出して再生ヘッドを移動する")
	public function gotoGlobalAndPlay_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Animation(createTextures(6), sections);
		// gotoAndPlayを呼び出すと同時にテクスチャが切り替わる（表示は変化しない）
		sut.gotoGlobalAndPlay(4);
		Assert.areEqual(4, sut.currentFrame);
		// gotoAndPlay呼び出し後、初めて描画されるテクスチャは「5」
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("生成直後にgotoAndPlayを呼び出して再生ヘッドを移動する")
	public function gotoAndPlay_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Animation(createTextures(6), sections);
		// gotoAndPlayを呼び出すと同時にテクスチャが切り替わる（表示は変化しない）
		sut.gotoAndPlay("b");
		Assert.areEqual(4, sut.currentFrame);
		// gotoAndPlay呼び出し後、初めて描画されるテクスチャは「5」
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
	}
	
	@Test("生成直後にgotoGlobalAndStopを呼び出して再生ヘッドを移動する")
	public function gotoGlobalAndStop_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Animation(createTextures(6), sections);
		// 生成直後のフレームは「1」
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoGlobalAndStop(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("生成直後にgotoAndStopを呼び出して再生ヘッドを移動する")
	public function gotoAndStop_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Once, begin: 1, end: 3 },
			{ name: "b", kind: SectionKind.Once, begin: 4, end: 6}
		];
		var sut = new Animation(createTextures(6), sections);
		// 生成直後のフレームは「1」
		Assert.areEqual(1, sut.currentFrame);
		sut.gotoAndStop("b");
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
	}
	
	@Test("gotoGlobalAndStop呼び出し後にplayを呼び出す")
	public function gotoGlobalAndStop_play_currentFrame():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 6 }
		];
		var sut = new Animation(createTextures(6), sections);
		Assert.areEqual(1, sut.currentFrame);
		
		sut.gotoGlobalAndStop(4);
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(4, sut.currentFrame);
		
		sut.play();
		Assert.areEqual(4, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(5, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(6, sut.currentFrame);
	}
	
	@Ignore("あとでこの仕様を許容するかどうか判断する")
	@Test("生成直後に停止し、その後再生した場合はすぐに動き出す")
	public function afterConstruct_stop_play():Void {
		var sections = [
			{ name: "a", kind: SectionKind.Pass, begin: 1, end: 6 }
		];
		var sut = new Animation(createTextures(6), sections);
		sut.stop();
		sut.advanceTime(1.0);
		sut.advanceTime(1.0);
		sut.advanceTime(1.0);
		Assert.areEqual(1, sut.currentFrame);
		sut.play();
		Assert.areEqual(1, sut.currentFrame);
		sut.advanceTime(1.0);
		Assert.areEqual(2, sut.currentFrame);
	}
	
}
