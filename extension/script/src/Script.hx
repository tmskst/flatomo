package ;

import flatomo.DocumentStatus;
import flatomo.ExtendedItem;
import flatomo.exporter.Exporter;
import flatomo.ExtensionItem;
import flatomo.ExtensionLibrary;
import flatomo.util.DocumentTools;
import haxe.Serializer;
import haxe.Unserializer;
import js.Lib;
import jsfl.Document;
import jsfl.Item;
import jsfl.ItemType;
import jsfl.Lib.fl;
import jsfl.Library;
import jsfl.SymbolItem;

using Lambda;
using flatomo.util.DocumentTools;
using flatomo.util.LibraryTools;
using flatomo.util.SymbolItemTools;

class Script {
	
	public static function main() { trace("Extension"); }
	
	public static function invoke(command_raw:String):Serialization {
		return Serializer.run(execute(Unserializer.run(command_raw)));
	}
	
	private static function execute(command:ScriptApi):Dynamic {
		var document:Document = fl.getDocumentDOM();
		var library:Library = document.library;
		
		switch (command) {
			case ScriptApi.Enable :
				document.enableFlatomo();
			case ScriptApi.Disable :
				document.disableFlatomo();
			case ScriptApi.ValidationTest :
				return if (document == null) Invalid else if (document.isFlatomo()) Enabled else Disabled;
			case ScriptApi.SelectItem(itemPath) :
				library.selectItem(itemPath);
			case ScriptApi.GetExtensionLibrary :
				return document.library.symbolItems().map(function (item) return item.name);
			case ScriptApi.GetExtensionItem(name) :
				return getExtensionItem(name);
			case ScriptApi.SetExtensionItem(item) :
				setExtensionItem(item);
			case ScriptApi.GetPublishProfile :
				return document.getPublishProfile();
			case ScriptApi.SetPublishProfile(publishProfile) :
				document.setPublishProfile(publishProfile);
			case ScriptApi.Export :
				Exporter.export(document);
		}
		return 0;
	}
	
	private static function getExtensionItem(name:String):ExtensionItem {
		var symbolItem:SymbolItem = untyped fl.getDocumentDOM().library.getItem(name);
		var extendedItem:ExtendedItem = symbolItem.getExtendedItem();
		return {
			name: symbolItem.name,
			linkageClassName: symbolItem.linkageClassName, 
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
