package flatomo;

class Debugger {

	#if flatomo_debug_export_atlas
	public static function export(atlases:Array<{ image:flash.display.BitmapData, layout:flash.xml.XML }>):Void {
		var entries:List<format.zip.Data.Entry> = new List();
		for (index in 0...atlases.length) {
			var atlas = atlases[index];
			entries.add(ofImage(atlas.image, 'atlas${index}.png'));
			entries.add(ofXml(atlas.layout, 'atlas${index}.xml'));
		}
		var output = new haxe.io.BytesOutput();
		new haxe.zip.Writer(output).write(entries);
		new flash.net.FileReference().save(output.getBytes().getData(), "atlas.zip");
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
	
}
