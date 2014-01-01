package flatomo;

/**
 * 再生ヘッドを制御するための制御コードの列挙。
 */
enum ControlCode {
	/**
	 * 再生ヘッドを移動させる。
	 * @param	frame 移動先のフレーム。
	 */
	Goto(frame:Int);
	/** 再生ヘッドを停止させる。 */
	Stop;
}
