package flatomo;

/** 'jsfl.Item'と'flatomo.ExtendedItem'をパネルとツールの間で共有するための構造体 */
typedef ExtensionItem = {
	/** @inheritDoc */
	> ExtendedItem,
	/** jsfl.Item.name と同じ */
	name:String,
	/** jsfl.Item.linkageClassName と同じ */
	linkageClassName:String,
}
