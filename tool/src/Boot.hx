package ;

import flash.desktop.NativeApplication;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flatomo.Structure;
import flatomo.Timeline;
import haxe.Unserializer;
import mcli.Dispatch;

using Lambda;

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
		return ErrorCode.Successful;
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
	
}
