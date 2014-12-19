package ;

import flash.desktop.NativeApplication;
import mcli.CommandLine;

class Args extends CommandLine {
	/** @alias n */
	public var name:String;
	/** @alias o */
	public var output:String;
	/** @alias i */
	public var inputs:Map<String, String> = new Map<String, String>();
	/** @alias h */
	public function help():Void {
		trace(this.showUsage());
	}
	/* runDefault */
	public function runDefault():Void {
		
	}
}
