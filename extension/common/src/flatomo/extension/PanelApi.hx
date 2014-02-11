package flatomo.extension;

enum PanelApi {
	/**
	 * パネルを更新する。
	 * @param latestSection タイムラインから取得したセクション情報。すべてのkind属性は初期値。
	 */
	Refresh(latestSection:Array<Section>);
	/**
	 * 作業タイムラインが変更されたことをパネルに通知する。
	 * @param latestSection タイムラインから取得したセクション情報。すべてのkind属性は初期値。
	 * @param savedItem Flash CC(Item)に保存されているデータ。保存されているデータが存在しない場合はnull。
	 */
	TimlineSelected(latestSection:Array<Section>, savedItem:Null<FlatomoItem>);
	/**
	 * ライブラリ内に存在しない（FlatomoItemが保存できない）タイムラインが選択されたことをパネルに通知する。
	 */
	DisabledTimlineSelected;
}