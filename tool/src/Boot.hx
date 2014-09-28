package ;

import flatomo.Structure;
import flatomo.Timeline;
import haxe.Serializer;
import haxe.Unserializer;
import mcli.Dispatch;
import sys.FileSystem;
import sys.io.File;

class Boot {
	
	public static function main() {
		var args:Args = new Args();
		new Dispatch(Sys.args()).dispatch(args);
		
		var directories = [for (input in args.inputs.keys()) input];
		
		var config:Config = {
			root  : FileSystem.fullPath('.'),
			output: args.output,
			inputs: directories,
			unifiedStructures : unifyStructures(directories),
			unifiedTimelines  : unifyTimelines(directories),
		};
		
		Sys.command('adl ../application.xml -- ' + Serializer.run(config));
	}
	
	private static function unifyStructures(directories:Array<String>):Map<String, Structure> {
		var getStructures:String -> Map<String, Structure> = function (directoryPath) {
			return Unserializer.run(File.getContent(directoryPath + '/a.structure'));
		};
		
		var unifiedStructures = new Map<String, Structure>();
		for (directory in directories) {
			var structures:Map<String, Structure> = getStructures(directory);
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
	
	private static function unifyTimelines(directories:Array<String>):Map<String, Timeline> {
		var getTimelines:String -> Map<String, Timeline> = function (directoryPath) {
			return Unserializer.run(File.getContent(directoryPath + '/a.timeline'));
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
	
	private static function validate(directoryPath:String):Bool {
		return FileSystem.exists(directoryPath + 'a.timeline')
			&& FileSystem.exists(directoryPath + 'a.structure')
			&& FileSystem.isDirectory(directoryPath + 'src')
			&& FileSystem.isDirectory(directoryPath + 'texture');
	}
	
	private static function readDirectoryRecursive(basePath:String):Array<String> {
		var children = FileSystem.readDirectory(basePath);
		var files:Array<String> = [];
		for (child in children) {
			var filePath:String = basePath + '/' + child;
			if (FileSystem.isDirectory(filePath)) {
				files = files.concat(readDirectoryRecursive(filePath));
			} else {
				files.push(filePath);
			}
		}
		return files;
	}
	
}
