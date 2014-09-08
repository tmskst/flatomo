package flatomo;

/** ドキュメントの状態 */
enum DocumentStatus {
	/** ドキュメントでFlatomoが有効 */
	Enabled;
	/** ドキュメントでFlatomoが無効 */
	Disabled;
	/** ドキュメントが開かれていないか対応していないドキュメント*/
	Invalid;
}
