package ;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.PNGEncoderOptions;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.xml.XML;
import flatomo.GeometricTransform;
import flatomo.Structure;
import haxe.crypto.Sha1;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.Serializer;
import haxe.Unserializer;

using Lambda;

private typedef UniquelyTexture = {
	filePath:String,
	transform:GeometricTransform,
};

class Tool {
	
	public static function main() {
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, initialize);
	}
	
	private static var uniquelyTextures:Array<UniquelyTexture>;
	private static var resolver:String -> UniquelyTexture;
	private static var uniquelyData:Map<UniquelyTexture, Bitmap>;
	private static var root:File;
	private static var config:Config;
	
	private static var unifiedStructures:Map<String, Structure>;
	private static var unifiedTimelines:Map<String, Structure>;
	
	private static function initialize(event:InvokeEvent):Void {
		config = Unserializer.run(event.arguments[0]);
		root = new File(config.root);
		
		var s = new FileStream();
		s.open(root.resolvePath('./u.structure'), FileMode.READ);
		unifiedStructures = Unserializer.run(s.readUTFBytes(s.bytesAvailable));
		s.close();
		
		s.open(root.resolvePath('./u.timeline'), FileMode.READ);
		unifiedTimelines = Unserializer.run(s.readUTFBytes(s.bytesAvailable));
		s.close();
		
		uniquelyData = new Map<UniquelyTexture, Bitmap>();
		{
			var nonDuplicated = new Map<String, UniquelyTexture>();
			var anyTextureFromHash = new Map<String, UniquelyTexture>();
			
			for (directoryPath in config.inputs) {
				var directory = root.resolvePath(directoryPath + '/texture');
				for (file in readDirectoryRecursive(directory)) {
					var fileStream = new FileStream();
					fileStream.open(file, FileMode.READ);
					
					var bytesData = new BytesData();
					fileStream.readBytes(bytesData, 0, fileStream.bytesAvailable);
					
					var hash:String = Sha1.make(Bytes.ofData(bytesData)).toHex();
					var filePath:String = root.getRelativePath(file, true);
					filePath = filePath.substring(0, filePath.lastIndexOf('.'));
					
					if (!anyTextureFromHash.exists(hash)) {
						anyTextureFromHash.set(hash, {
							filePath  : filePath,
							transform : { a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0 },
						});
					}
					nonDuplicated.set(filePath, anyTextureFromHash.get(hash));
					
					fileStream.close();
				}
			}
			
			uniquelyTextures = Lambda.array(anyTextureFromHash);
			resolver = function (name) {
				return nonDuplicated.get(name);
			};
		}
		
		for (key in unifiedStructures.keys()) {
			var structure = unifiedStructures.get(key);
			switch (structure) {
				case Container(children) | PartsAnimation(children) :
					for (child in children) {
						for (layout in child.layouts) {
							if (layout != null) { 
							var mat = layout.transform;
							var scaleX:Float = Math.sqrt(mat.a * mat.a + mat.b * mat.b);
							var scaleY:Float = Math.sqrt(mat.c * mat.c + mat.d * mat.d);
							var uniquelyTexture = resolver(child.path);
							uniquelyTexture.transform.a = Math.min(Math.max(uniquelyTexture.transform.a, scaleX), 1.0);
							uniquelyTexture.transform.d = Math.min(Math.max(uniquelyTexture.transform.d, scaleY), 1.0);
							}
						}
					}
				case Animation :
					//var uniquelyTexture = resolver(key);
					//trace(uniquelyTexture == null, key);
					//uniquelyTexture.transform.a = Math.min(Math.max(uniquelyTexture.transform.a, 1.0), 1.0);
					//uniquelyTexture.transform.d = Math.min(Math.max(uniquelyTexture.transform.d, 1.0), 1.0);
				case Image(_) :
					
			}
		}
		
		var loaded:Array<Bool> = [for (i in 0...uniquelyTextures.length) false];
		
		for (index in 0...uniquelyTextures.length) {
			var uniquelyTexture = uniquelyTextures[index];
			
			var fileStream = new FileStream();
			fileStream.open(root.resolvePath(uniquelyTexture.filePath + '.png'), FileMode.READ);
			
			var bytesData = new BytesData();
			fileStream.readBytes(bytesData, 0, fileStream.bytesAvailable);
			
			var loader = new Loader();
			loader.loadBytes(bytesData);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event) {
				
				var bitmapData:BitmapData = new BitmapData(Std.int(loader.width), Std.int(loader.height), true, 0x00000000);
				bitmapData.draw(loader);
				
				var bounds = bitmapData.getColorBoundsRect(0xFF000000, 0x00000000, false);
				uniquelyTexture.transform.tx = uniquelyTexture.transform.tx - bounds.x;
				uniquelyTexture.transform.ty = uniquelyTexture.transform.ty - bounds.y;
				
				var trimed = new BitmapData(Std.int(bounds.width), Std.int(bounds.height), true, 0x00000000);
				trimed.copyPixels(bitmapData, bounds, new Point());
				
				var t = new Matrix(1, 0, 0, 1, uniquelyTexture.transform.tx, uniquelyTexture.transform.ty);
				if (uniquelyTexture.transform.a == 0 || uniquelyTexture.transform.d == 0) {
					uniquelyTexture.transform.a = 1;
					uniquelyTexture.transform.d = 1;
				}
				var s = new Matrix(uniquelyTexture.transform.a, 0, 0, uniquelyTexture.transform.d, 0, 0);
				
				var bitmap = new Bitmap(trimed);
				var k = s.clone();
				k.concat(t);
				bitmap.transform.matrix = k;
				
				uniquelyTexture.transform.a = k.a;
				uniquelyTexture.transform.b = k.b;
				uniquelyTexture.transform.c = k.c;
				uniquelyTexture.transform.d = k.d;
				uniquelyTexture.transform.tx = k.tx;
				uniquelyTexture.transform.ty = k.ty;
				
				var r = new Bitmap(new BitmapData(Std.int(bitmap.width), Std.int(bitmap.height), true, 0x00000000));
				r.bitmapData.draw(bitmap, s);
				
				uniquelyData.set(uniquelyTexture, r);
				
				loaded[index] = true;
				
				if (loaded.fold(function (a, b) return a && b, true)) {
					loadComplete();
				}
			});
		}
		
	}
	
	private static function loadComplete():Void {
		for (uniquelyTexture in uniquelyTextures) {
			unifiedStructures.set(uniquelyTexture.filePath, Image(uniquelyTexture.transform));
		}
		
		
		var stream = new FileStream();
		stream.open(root.resolvePath(config.output).resolvePath('./a.structure'), FileMode.WRITE);
		stream.writeUTFBytes(Serializer.run(unifiedStructures));
		stream.close();
		
		stream.open(root.resolvePath(config.output).resolvePath('./a.timeline'), FileMode.WRITE);
		stream.writeUTFBytes(Serializer.run(unifiedTimelines));
		stream.close();
		
		var images:Array<RawTexture> = [];
		for (uniquelyTexture in uniquelyTextures) {
			images.push({
				name: uniquelyTexture.filePath,
				index: 0,
				image: uniquelyData.get(uniquelyTexture).bitmapData,
				frame: uniquelyData.get(uniquelyTexture).bitmapData.rect,
				unionBounds: uniquelyData.get(uniquelyTexture).bitmapData.rect,
			});
		}
		
		var atlases = AtlasGenerator.generate(images);
		for (atlas in atlases) {
			var imageStream = new FileStream();
			imageStream.open(root.resolvePath(config.output).resolvePath('./a.png'), FileMode.WRITE);
			var bytes = atlas.image.encode(atlas.image.rect, new PNGEncoderOptions());
			imageStream.writeBytes(bytes, 0, bytes.length);
			imageStream.close();
			
			XML.prettyPrinting = true;
			XML.prettyIndent = 4;
			var xmlStream = new FileStream();
			
			xmlStream.open(root.resolvePath(config.output).resolvePath('./a.xml'), FileMode.WRITE);
			xmlStream.writeUTFBytes(atlas.layout.toXMLString());
			xmlStream.close();
		}
	}
	
	private static function readDirectoryRecursive(root:File):Array<File> {
		var children:Array<File> = [];
		for (child in root.getDirectoryListing()) {
			if (child.isDirectory) {
				children = children.concat(readDirectoryRecursive(child));
			} else {
				children.push(child);
			}
		}
		return children;
	}
	
}
