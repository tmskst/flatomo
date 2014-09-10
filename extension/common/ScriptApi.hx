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
	/** 作業中のドキュメントからパブリッシュプロファイルを取得します */
	GetPublishProfile;
	/** 作業中のドキュメントにパブリッシュプロファイルを設定します */
	SetPublishProfile(publishProfile:PublishProfile);
	/** 出力する */
	Export;
}
