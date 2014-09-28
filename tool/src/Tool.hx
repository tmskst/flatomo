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
	
	private static function initialize(event:InvokeEvent):Void {
		var config:Config = Unserializer.run(event.arguments[0]);
		root = new File(config.root);
		
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
					
					if (!anyTextureFromHash.exists(hash)) {
						anyTextureFromHash.set(hash, {
							filePath  : filePath,
							transform : { a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0 },
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
		
		for (key in config.unifiedStructures.keys()) {
			var structure = config.unifiedStructures.get(key);
			switch (structure) {
				case Container(children) | PartsAnimation(children) :
					for (child in children) {
						for (layout in child.layouts) {
							var mat = layout.transform;
							var scaleX:Float = Math.sqrt(mat.a * mat.a + mat.b * mat.b);
							var scaleY:Float = Math.sqrt(mat.c * mat.c + mat.d * mat.d);
							var uniquelyTexture = resolver(child.path + '.png');
							uniquelyTexture.transform.a = Math.max(Math.min(uniquelyTexture.transform.a, scaleX), 0.0);
							uniquelyTexture.transform.d = Math.max(Math.min(uniquelyTexture.transform.d, scaleY), 0.0);
						}
					}
				case _ :
					
			}
		}
		
		var loaded:Array<Bool> = [for (i in 0...uniquelyTextures.length) false];
		
		for (index in 0...uniquelyTextures.length) {
			var uniquelyTexture = uniquelyTextures[index];
			
			var fileStream = new FileStream();
			fileStream.open(root.resolvePath(uniquelyTexture.filePath), FileMode.READ);
			
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
				
				var bitmap = new Bitmap(trimed);
				bitmap.transform.matrix = new Matrix(
					uniquelyTexture.transform.a,
					uniquelyTexture.transform.b,
					uniquelyTexture.transform.c,
					uniquelyTexture.transform.d,
					uniquelyTexture.transform.tx,
					uniquelyTexture.transform.ty
				);
				
				uniquelyData.set(uniquelyTexture, bitmap);
				
				loaded[index] = true;
				
				if (loaded.fold(function (a, b) return a && b, true)) {
					loadComplete();
				}
			});
		}
		
	}
	
	private static function loadComplete():Void {
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
			imageStream.open(root.resolvePath('./x.png'), FileMode.WRITE);
			var bytes = atlas.image.encode(atlas.image.rect, new PNGEncoderOptions());
			imageStream.writeBytes(bytes, 0, bytes.length);
			imageStream.close();
			
			XML.prettyPrinting = true;
			XML.prettyIndent = 4;
			var xmlStream = new FileStream();
			xmlStream.open(root.resolvePath('./x.xml'), FileMode.WRITE);
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
