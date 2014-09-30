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
	
	private static function exit(code:Int):Void {
		NativeApplication.nativeApplication.exit(code);
	}
	
	private static function initialize(event:InvokeEvent) {
		var cwd:File = event.currentDirectory;
		var apd:File = File.applicationDirectory;
		
		trace('cwd -> ${cwd.nativePath}');
		trace('apd -> ${apd.nativePath}');
		
		var args:Args = new Args();
		new Dispatch([for (v in event.arguments) v]).dispatch(args);
		var inputs = [for (input in args.inputs.keys()) cwd.resolvePath(input)];
		
		// TODO : 入力が指定されていないとき　
		// TODO : 出力が指定されていないとき
		
		var fails = inputs.filter(function (f) return !validate(f));
		if (!fails.empty()) {
			fails.iter(function (f) trace('invaild source : ' + f.nativePath));
			exit(1);
		}
		else {
			unifyStructures(inputs);
			unifyTimelines(inputs);
			exit(0);
		}
	}
	
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
							child.path = directory + '/texture/' + child.path;
						}
					case _ : 
						
				}
				unifiedStructures.set(directory + '/texture/' + key, structure);
			}
		}
		
		return unifiedStructures;
	}
	
	private static function unifyTimelines(directories:Array<File>):Map<String, Timeline> {
		var getTimelines:File -> Map<String, Timeline> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.timeline')));
		};
		
		var unifiedTimelines = new Map<String, Timeline>();
		for (directory in directories) {
			var timelines:Map<String, Timeline> = getTimelines(directory);
			for (key in timelines.keys()) {
				unifiedTimelines.set(directory + '/texture/' + key, timelines.get(key));
			}
		}
		return unifiedTimelines;
	}
	
	private static function validate(directory:File):Bool {
		return directory.isDirectory
		    && directory.resolvePath('a.timeline').exists
		    && directory.resolvePath('a.structure').exists
		    && directory.resolvePath('src').isDirectory
		    && directory.resolvePath('texture').isDirectory;
	}
	
}
