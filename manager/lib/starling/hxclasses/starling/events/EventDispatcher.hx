package starling.events;

extern class EventDispatcher {
	function new() : Void;
	function addEventListener(p1 : String, p2 : flash.utils.Function) : Void;
	function bubbleEvent(p1 : Event) : Void;
	function dispatchEvent(p1 : Event) : Void;
	function dispatchEventWith(p1 : String, p2 : Bool = false, ?p3 : flash.utils.Object) : Void;
	function hasEventListener(p1 : String) : Bool;
	function invokeEvent(p1 : Event) : Bool;
	function removeEventListener(p1 : String, p2 : flash.utils.Function) : Void;
	function removeEventListeners(?p1 : String) : Void;
}
