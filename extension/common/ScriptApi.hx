package ;

import flatomo.ExtensionItem;

enum ScriptApi {
	ValidationTest;
	GetExtensionLibrary;
	GetExtensionItem(name:String);
	SetExtensionItem(item:ExtensionItem);
}
