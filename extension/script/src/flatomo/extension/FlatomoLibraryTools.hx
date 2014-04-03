package flatomo.extension;

import flatomo.FlatomoLibrary;
import haxe.Serializer;
import jsfl.Document;
import jsfl.FLfile;

class FlatomoLibraryTools {
	
	/** FlatomoLibraryをファイルに書き込みます */
	private static function publish(library:FlatomoLibrary, document:Document):Void {
		var swfPath:String = document.getSWFPathFromProfile();
		{ // *.flatomo を書き出す
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf(".")) + "." + "flatomo";
			FLfile.write(fileUri, Serializer.run(library));
		}
		{ // extern定義（*.hx）を書き出す
			var fileUri = swfPath.substring(0, swfPath.lastIndexOf("/"));
			var files = HxClassesCreator.export(library);
			for (file in files) {
				FLfile.write(fileUri + "/" + file.name + ".hx", file.value);
			}
		}
	}
	
}
