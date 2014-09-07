package ;

import flatomo.ExtensionItem;

enum ScriptApi {
	Enable;
	Disable;
	ValidationTest;
	GetExtensionLibrary;
	GetExtensionItem(name:String);
	SetExtensionItem(item:ExtensionItem);
}
