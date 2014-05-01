package flatomo;

#if debugFlatomo
import flash.display.BitmapData;
import flash.display.PNGEncoderOptions;
import flash.net.FileReference;
import flash.xml.XML;
import format.zip.Data.Entry;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.zip.Writer;
#end

import haxe.Unserializer;

class Debugger {

	#if debugFlatomo
	public static function export(data:Asset):Void {
		var entries:List<Entry> = new List();
		for (index in 0...data.atlases.length) {
			var atlas = data.atlases[index];
			entries.add(ofImage(atlas.image, 'atlas${index}.png'));
			entries.add(ofXml(atlas.layout, 'atlas${index}.xml'));
		}
		entries.add(ofPostures(data.postures));
		var output = new BytesOutput();
		new Writer(output).write(entries);
		new FileReference().save(output.getBytes().getData(), "atlas.zip");
	}
	
	private static function ofPostures(postures:Map<ItemPath, Posture>) {
		var buf = new StringBuf();
		for (key in postures.keys()) {
			var value:Posture = postures.get(key);
			buf.add('${key} : ${value}\r\n');
		}
		return toEntry(Bytes.ofString(buf.toString()), "postures.txt");
	}
	
	private static function ofXml(xml:XML, fileName:String):Entry {
		var bytes = Bytes.ofString(xml.toXMLString());
		return toEntry(bytes, fileName);
	}
	
	private static function ofImage(image:BitmapData, fileName:String):Entry {
		var bytes = Bytes.ofData(image.encode(image.rect, new PNGEncoderOptions()));
		return toEntry(bytes, fileName);
	}
	
	private static function toEntry(bytes:Bytes, fileName:String):Entry {
		return {
			fileName : fileName,
			fileSize : bytes.length,
			fileTime : Date.now(),
			compressed : false,
			dataSize : 0,
			data : bytes,
			crc32 : Crc32.make(bytes),
			extraFields : new List()
		};
	}
	#end
	
	public static function decode(flatomo:String):String {
		var buf = new StringBuf();
		var data:FlatomoLibrary = Unserializer.run(flatomo);
		
		buf.add('# extendedItems:Map<ItemPath, FlatomoItem>\r\n');
		for (key in data.extendedItems.keys()) {
			buf.add('${key} => ${data.extendedItems.get(key)}\r\n');
		}
		buf.add('# itemPaths:Map<ElementPath, ItemPath>\r\n');
		for (key in data.itemPaths.keys()) {
			buf.add('${key} => ${data.itemPaths.get(key)}\r\n');
		}
		return buf.toString();
	}
	
}
