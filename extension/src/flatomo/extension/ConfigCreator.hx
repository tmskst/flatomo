package flatomo.extension;
import flatomo.FlatomoItem;
import flatomo.FlatomoTools;
import flatomo.LibraryPath;
import flatomo.Section;
import flatomo.SectionKind;
import haxe.Serializer;

class ConfigCreator {
	
	public static function main() {
		var flash:Flash = untyped fl;
		var items:Array<Item> = flash.getDocumentDOM().library.items;
		
		FlatomoTools.setElement(items);
		FlatomoTools.setLibrary(FlatomoTools.createLibrary(items));
	}
	
}
