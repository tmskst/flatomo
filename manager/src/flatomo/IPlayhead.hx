package flatomo;

/** 再生ヘッドを持つことを保証する */
interface IPlayhead {
	public var playhead(default, null):Playhead;
}
