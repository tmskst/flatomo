package flatomo;
import flatomo.util.StringMapUtil;

class LogicClipManager {
	
	private var timelines:Map<String, Timeline>;
	
	public function new() {
		this.timelines = new Map<String, Timeline>();
	}
	
	public function addEmbedAsset(asset:Asset):Void {
		var timeline = EmbedAsset.getTimeline(asset);
		timelines = StringMapUtil.unite([timelines, timeline]);
	}
	
	public function getLogicClip(key:String):LogicClip {
		return new LogicClip(timelines.get(key));
	}
	
}
