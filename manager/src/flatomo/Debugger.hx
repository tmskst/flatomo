package flatomo;

class Debugger {

	#if flatomo_debug_export_atlas
	public static function export(data: { atlases:Array<{image:flash.display.BitmapData, layout:flash.xml.XML}>, metaData:Map<String, Meta> } ):Void {
		var entries:List<format.zip.Data.Entry> = new List();
		for (index in 0...data.atlases.length) {
			var atlas = data.atlases[index];
			entries.add(ofImage(atlas.image, 'atlas${index}.png'));
			entries.add(ofXml(atlas.layout, 'atlas${index}.xml'));
		}
		entries.add(ofMetadata(data.metaData));
		var output = new haxe.io.BytesOutput();
		new haxe.zip.Writer(output).write(entries);
		new flash.net.FileReference().save(output.getBytes().getData(), "atlas.zip");
	}
	
	static private function ofMetadata(metadata:Map<String, Meta>) {
		var buf = new StringBuf();
		for (key in metadata.keys()) {
			var value:Meta = metadata.get(key);
			buf.add('${key} : ${value}\r\n');
		}
		return toEntry(haxe.io.Bytes.ofString(buf.toString()), "metadata.txt");
	}
	
	private static function ofXml(xml:flash.xml.XML, fileName:String):haxe.zip.Entry {
		var bytes = haxe.io.Bytes.ofString(xml.toXMLString());
		return toEntry(bytes, fileName);
	}
	
	private static function ofImage(image:flash.display.BitmapData, fileName:String):haxe.zip.Entry {
		var bytes = haxe.io.Bytes.ofData(image.encode(image.rect, new flash.display.PNGEncoderOptions()));
		return toEntry(bytes, fileName);
	}
	
	private static function toEntry(bytes:haxe.io.Bytes, fileName:String):haxe.zip.Entry {
		return {
			fileName : fileName,
			fileSize : bytes.length,
			fileTime : Date.now(),
			compressed : false,
			dataSize : 0,
			data : bytes,
			crc32 : haxe.crypto.Crc32.make(bytes),
			extraFields : new List()
		};
	}
	#end
	
	public static function decode(flatomo:String):String {
		var buf:StringBuf = new StringBuf();
		var data:FlatomoLibrary = haxe.Unserializer.run(flatomo);
		
		buf.add('# metadata:Map<LibraryPath, FlatomoItem>\r\n');
		for (key in data.metadata.keys()) {
			buf.add('${key} : ${data.metadata.get(key)}\r\n');
		}
		buf.add('# libraryPaths:Map<ElementPath, LibraryPath>\r\n');
		for (key in data.libraryPaths.keys()) {
			buf.add('${key} : ${data.libraryPaths.get(key)}\r\n');
		}
		return buf.toString();
	}
	
}
