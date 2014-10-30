package ;

import flatomo.ExtendedItem;
import flatomo.ExtensionItem;
import flatomo.Parser;
import flatomo.Publisher;
import haxe.Serializer;
import haxe.Unserializer;
import jsfl.Document;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.SymbolItem;

using Lambda;
using flatomo.util.DocumentTools;
using jsfl.util.LibraryUtil;
using flatomo.util.SymbolItemTools;

class Script {
	
	public static function main() { trace("Extension"); }
	
	public static function invoke(command_raw:String):Serialization {
		return Serializer.run(execute(Unserializer.run(command_raw)));
	}
	
	private static function execute(command:ScriptApi):Dynamic {
		var document:Document = fl.getDocumentDOM();
		
		switch (command) {
			case ScriptApi.Enable :
				document.enableFlatomo();
			case ScriptApi.Disable :
				document.disableFlatomo();
			case ScriptApi.ValidationTest :
				return document.validationTest();
			case ScriptApi.SelectItem(itemPath) :
				var library:Library = document.library;
				library.selectItem(itemPath);
			case ScriptApi.GetExtensionLibrary :
				return document.library.symbolItems().map(function (item) return item.name);
			case ScriptApi.GetExtensionItem(name) :
				return getExtensionItem(name);
			case ScriptApi.SetExtensionItem(item) :
				setExtensionItem(item);
			case ScriptApi.GetPublishPath :
				return document.getPublishPath();
			case ScriptApi.SetPublishPath(publishPath) :
				document.setPublishPath(publishPath);
			case ScriptApi.Export :
				Publisher.publish(document.library, document.getPublishProfile());
		}
		return 0;
	}
	
	private static function getExtensionItem(name:String):ExtensionItem {
		var symbolItem:SymbolItem = untyped fl.getDocumentDOM().library.getItem(name);
		var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
		return {
			name: symbolItem.name,
			linkageClassName: symbolItem.linkageClassName, 
			areChildrenAccessible: extendedItem.areChildrenAccessible,
			linkageExportForFlatomo: extendedItem.linkageExportForFlatomo,
			exportClassKind: extendedItem.exportClassKind,
			sections: extendedItem.sections,
		};
	}
	
	@:access(flatomo.util.SymbolItemTools)
	private static function setExtensionItem(extensionItem:ExtensionItem):Void {
		var symbolItem:SymbolItem = untyped fl.getDocumentDOM().library.getItem(extensionItem.name);
		if (extensionItem.linkageExportForFlatomo) {
			symbolItem.linkageExportForAS = true;
			symbolItem.linkageClassName = extensionItem.linkageClassName;
		}
		symbolItem.setExtendedItem(extensionItem);
	}
	
}
