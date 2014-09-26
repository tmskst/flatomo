package ;

import flatomo.ExtensionItem;
import flatomo.PublishProfile;

/** パネルから呼び出すことのできるツールのAPI */
enum ScriptApi {
	/** 現在のドキュメントでFlatomoを有効にする */
	Enable;
	/** 現在のドキュメントでFlatomoを無効にする */
	Disable;
	/** 現在のドキュメントでFlatomoが利用可能かどうか検証をする */
	ValidationTest;
	/** ライブラリアイテムを選択する */
	SelectItem(itemPath:String);
	/** ExtensionLibraryをjsfl.Libraryから取得する */
	GetExtensionLibrary;
	/**
	 * ExtensionItemをjsfl.Itemから取得する
	 * @param name 対象のjsfl.Item.name
	 */
	GetExtensionItem(name:String);
	/**
	 * ExtensionItemをjsfl.Itemに保存する
	 * @param name 保存するExtensionItem
	 */
	SetExtensionItem(item:ExtensionItem);
	/** 作業中のドキュメントから出力先のパスを取得します */
	GetPublishPath;
	/** 作業中のドキュメントに出力先のパスを設定します */
	SetPublishPath(publishPath:String);
	/** 出力する */
	Export;
}
