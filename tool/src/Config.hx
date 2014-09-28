package ;

import flatomo.Structure;
import flatomo.Timeline;

typedef Config = {
	output:String,
	inputs:Array<String>,
	unifiedStructures:Map<String, Structure>,
	unifiedTimelines:Map<String, Timeline>,
}
