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

private typedef V = {
	resolver:Map<String, U>,
	required:Array<U>,
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
		
		var args:Args = new Args();
		new Dispatch([for (v in event.arguments) v]).dispatch(args);
		
		// -o <output directory>
		if (args.output == null) {
			return ErrorCode.MissingArgumentOuput;
		}
		var output:File = cwd.resolvePath(args.output);
		
		// -i <input directory>
		var inputs = [for (input in args.inputs.keys()) cwd.resolvePath(input)];
		if (inputs.empty()) {
			return ErrorCode.MissingArgumentInput;
		}
		
		var fails = inputs.filter(function (f) return !validate(f));
		if (!fails.empty()) {
			fails.iter(function (f) trace('invaild input : ' + f.nativePath));
			return ErrorCode.InvaildArgumentInput;
		}
		
		// valid arguments
		var unifiedStructures = unifyStructures(inputs);
		var unifiedTimelines = unifyTimelines(inputs);
		
		#if debug
		trace('cwd -> ${cwd.nativePath}');
		trace('apd -> ${apd.nativePath}');
		trace('-o  -> ${output.nativePath}');
		inputs.iter(function (f) trace('-i  -> ' + f.nativePath));
		for (key in unifiedStructures.keys()) { trace(key); }
		for (key in unifiedTimelines.keys()) { trace(key); }
		#end
		
		var uniquely = pruneDuplicateTexture(inputs);
		scaleTexture(unifiedStructures, uniquely);
		
		return ErrorCode.Successful;
	}
	
	/** 重複したテクスチャをそぎ落とす */
	private static function pruneDuplicateTexture(inputs:Array<File>):V {
		var files:Array<File> = cast inputs
			.map(function (f) return f.resolvePath('./texture/'))
			.map(function (f) return readDirectoryRecursive(f))
			.flatten();
		
		var fromItem = new Map<String, U>();
		var fromHash = new Map<String, U>();
		
		for (file in files) {
			var hash:String = Sha1.make(FileUtil.getBytes(file)).toHex();
			
			#if debug
			if (fromHash.exists(hash)) {
				trace('duplicate -> ' + fromHash.get(hash).filePath + ', ' + file.nativePath);
			}
			#end
			
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
	
	/** テクスチャを必要とされている最大の大きさに縮小する */
	private static function scaleTexture(unifiedStructures:Map<String, Structure>, uniquely:V):Void {
		// TODO : 改善可能
		for (key in unifiedStructures.keys()) {
			switch (unifiedStructures.get(key)) {
				case PartsAnimation(children) :
					for (child in children) {
						var transform = uniquely.resolver.get(child.path).transform;
						for (layout in child.layouts) {
							if (layout != null) {
								var scaleX:Float = Math.sqrt(layout.transform.a * layout.transform.a + layout.transform.b * layout.transform.b);
								var scaleY:Float = Math.sqrt(layout.transform.c * layout.transform.c + layout.transform.d * layout.transform.d);
								transform.a = Math.min(Math.max(transform.a, scaleX), 1.0);
								transform.d = Math.min(Math.max(transform.d, scaleY), 1.0);
							}
						}
					}
				case Container(children) :
					
				case Animation(totalFrames) :
					switch (totalFrames) {
						case 1 : 
							var transform = uniquely.resolver.get(key).transform;
							transform.a = 1.0;
							transform.c = 1.0;
						case _ :
							for (index in 0...totalFrames) {
								var path:String = key + StringTools.lpad(Std.string(index + 1), '0', 4);
								var transform = uniquely.resolver.get(path).transform;
								transform.a = 1.0;
								transform.d = 1.0;
							}
					}
				case Image(_) :
					
			}
		}
	}
	
	/** 各々のライブラリが出力した構造情報のマップを1つにまとめる */
	private static function unifyStructures(inputs:Array<File>):Map<String, Structure> {
		var readStructures:File -> Map<String, Structure> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.structure')));
		};
		
		var unifiedStructures = new Map<String, Structure>();
		for (directory in inputs) {
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
	private static function unifyTimelines(inputs:Array<File>):Map<String, Timeline> {
		var readTimelines:File -> Map<String, Timeline> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.timeline')));
		};
		
		var unifiedTimelines = new Map<String, Timeline>();
		for (directory in inputs) {
			var timelines:Map<String, Timeline> = readTimelines(directory);
			for (key in timelines.keys()) {
				unifiedTimelines.set(resolvePath(directory, key), timelines.get(key));
			}
		}
		return unifiedTimelines;
	}
	
	// ユーティリティ
	// //////////////////////////////////////////////////////////////
	
	/** 拡張子を除いた'File.nativePath'を取得する */
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
	
	/** 指定したディレクトリの子を再帰的に走査し子の一覧を返す */
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
