package ;

import flash.desktop.NativeApplication;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flatomo.GeometricTransform;
import haxe.crypto.Sha1;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.Unserializer;

private typedef UniquelyTexture = {
	filePath:String,
	transform:GeometricTransform,
};

class Tool {
	
	public static function main() {
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, initialize);
	}
	
	private static function initialize(event:InvokeEvent):Void {
		var config:Config = Unserializer.run(event.arguments[0]);
		var root:File = new File(config.root);
		
		
		var uniquelyTextures:Array<UniquelyTexture>;
		var resolver:String -> UniquelyTexture;
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
		
		for (uniquelyTexture in uniquelyTextures) {
			trace(uniquelyTexture);
		}
		
		NativeApplication.nativeApplication.exit(0);
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
