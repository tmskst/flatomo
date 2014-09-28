package ;

import mcli.CommandLine;

class Args extends CommandLine {
	/** @alias o */
	public var output:String;
	/** @alias i */
	public var inputs:Map<String, String> = new Map<String, String>();
	/** @alias h */
	public function help():Void {
		Sys.println(this.showUsage());
	}
	/* runDefault */
	public function runDefault():Void {
		
	}
}
