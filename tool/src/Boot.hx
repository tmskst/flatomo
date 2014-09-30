package ;

import flash.desktop.NativeApplication;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flatomo.GeometricTransform;
import flatomo.Structure;
import flatomo.Timeline;
import haxe.crypto.Sha1;
import haxe.Unserializer;
import mcli.Dispatch;

using Lambda;
using flatomo.Collection;

private typedef U = {
	filePath:String,
	transform:GeometricTransform,
}

class Boot {
	
	public static function main() {
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, initialize);
	}
	
	private static function initialize(event:InvokeEvent) {
		NativeApplication.nativeApplication.exit(run(event));
	}
	
	private static function run(event:InvokeEvent):ErrorCode {
		var cwd:File = event.currentDirectory;
		var apd:File = File.applicationDirectory;
		
		trace('cwd -> ${cwd.nativePath}');
		trace('apd -> ${apd.nativePath}');
		
		var args:Args = new Args();
		new Dispatch([for (v in event.arguments) v]).dispatch(args);
		
		// -o <output directory>
		if (args.output == null) {
			return ErrorCode.MissingArgumentOuput;
		}
		var output:File = cwd.resolvePath(args.output);
		trace('-o  -> ${output.nativePath}');
		
		// -i <input directory>
		var inputs = [for (input in args.inputs.keys()) cwd.resolvePath(input)];
		if (inputs.empty()) {
			return ErrorCode.MissingArgumentInput;
		}
		inputs.iter(function (f) trace('-i  -> ' + f.nativePath));
		
		var fails = inputs.filter(function (f) return !validate(f));
		if (!fails.empty()) {
			fails.iter(function (f) trace('invaild input : ' + f.nativePath));
			return ErrorCode.InvaildArgumentInput;
		}
		
		for (key in unifyStructures(inputs).keys()) { trace(key); }
		for (key in unifyTimelines(inputs).keys()) { trace(key); }
		
		pruneDuplicateTexture(inputs);
		
		return ErrorCode.Successful;
	}
	
	private static function pruneDuplicateTexture(inputs:Array<File>) {
		var files:Array<File> = cast inputs
			.map(function (f) return f.resolvePath('./texture/'))
			.map(function (f) return readDirectoryRecursive(f))
			.flatten();
		
		var fromItem = new Map<String, U>();
		var fromHash = new Map<String, U>();
		
		for (file in files) {
			var hash:String = Sha1.make(FileUtil.getBytes(file)).toHex();
			if (!fromHash.exists(hash)) {
				fromHash.set(hash, { 
					filePath  : file.nativePath,
					transform : { a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0 },
				});
			}
			var delegate = fromHash.get(hash);
			fromItem.set(getNativePathWithoutExtension(file), delegate);
		}
		
		return {
			resolver : fromItem,
			required : Lambda.array(fromHash),
		};
	}
	
	
	/** 各々のライブラリが出力した構造情報のマップを1つにまとめる */
	private static function unifyStructures(directories:Array<File>):Map<String, Structure> {
		var readStructures:File -> Map<String, Structure> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.structure')));
		};
		
		var unifiedStructures = new Map<String, Structure>();
		for (directory in directories) {
			var structures:Map<String, Structure> = readStructures(directory);
			for (key in structures.keys()) {
				var structure:Structure = structures.get(key);
				switch (structure) {
					case Container(children) | PartsAnimation(children) : 
						for (child in children) {
							child.path = resolvePath(directory, child.path);
						}
					case _ : 
						
				}
				unifiedStructures.set(resolvePath(directory, key), structure);
			}
		}
		
		return unifiedStructures;
	}
	
	/** 各々のライブラリが出力したタイムラインのマップを1つにまとめる */
	private static function unifyTimelines(directories:Array<File>):Map<String, Timeline> {
		var readTimelines:File -> Map<String, Timeline> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.timeline')));
		};
		
		var unifiedTimelines = new Map<String, Timeline>();
		for (directory in directories) {
			var timelines:Map<String, Timeline> = readTimelines(directory);
			for (key in timelines.keys()) {
				unifiedTimelines.set(resolvePath(directory, key), timelines.get(key));
			}
		}
		return unifiedTimelines;
	}
	
	// ユーティリティ
	// //////////////////////////////////////////////////////////////
	
	private static function getNativePathWithoutExtension(file:File):String {
		return file.nativePath.substring(0, file.nativePath.lastIndexOf('.'));
	}
	
	private static function resolvePath(directory:File, key:String):String {
		return directory.resolvePath('./texture/').resolvePath(key).nativePath;
	}	
	
	private static function validate(directory:File):Bool {
		return directory.isDirectory
		    && directory.resolvePath('a.timeline').exists
		    && directory.resolvePath('a.structure').exists
		    && directory.resolvePath('src').isDirectory
		    && directory.resolvePath('texture').isDirectory;
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
