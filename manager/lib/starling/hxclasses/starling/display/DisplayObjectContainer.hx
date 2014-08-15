package starling.display;

extern class DisplayObjectContainer extends DisplayObject {
	var numChildren(default,never) : Int;
	var touchGroup : Bool;
	function new() : Void;
	function addChild(p1 : DisplayObject) : DisplayObject;
	function addChildAt(p1 : DisplayObject, p2 : Int) : DisplayObject;
	function broadcastEvent(p1 : starling.events.Event) : Void;
	function broadcastEventWith(p1 : String, ?p2 : flash.utils.Object) : Void;
	function contains(p1 : DisplayObject) : Bool;
	function getChildAt(p1 : Int) : DisplayObject;
	function getChildByName(p1 : String) : DisplayObject;
	function getChildEventListeners(p1 : DisplayObject, p2 : String, p3 : flash.Vector<DisplayObject>) : Void;
	function getChildIndex(p1 : DisplayObject) : Int;
	function removeChild(p1 : DisplayObject, p2 : Bool = false) : DisplayObject;
	function removeChildAt(p1 : Int, p2 : Bool = false) : DisplayObject;
	function removeChildren(p1 : Int = 0, p2 : Int = -1, p3 : Bool = false) : Void;
	function setChildIndex(p1 : DisplayObject, p2 : Int) : Void;
	function sortChildren(p1 : flash.utils.Function) : Void;
	function swapChildren(p1 : DisplayObject, p2 : DisplayObject) : Void;
	function swapChildrenAt(p1 : Int, p2 : Int) : Void;
}
