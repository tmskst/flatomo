package flatomo.extension;
import flatomo.FlatomoTools;

class ConfigCreator {
	
	public static function main() {
		var flash:Flash = untyped fl;
		var library:Library = flash.getDocumentDOM().library;
		
		FlatomoTools.setAllElementPersistentData(library);
		FlatomoTools.setLibrary(FlatomoTools.createLibrary(library));
	}
	
}
