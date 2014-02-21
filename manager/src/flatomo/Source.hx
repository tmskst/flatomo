package flatomo;

import flash.Vector;
import flatomo.Section;
import starling.textures.Texture;
import starling.display.DisplayObject;
import flash.display.BitmapData;

enum Source {
	Container(name:String, displayObjects:Array<String>, map:Map <Int, Array<Layout>> , sections:Array<Section>);
	Animation(name:String, textures:Array<BitmapData>, sections:Array<Section>);
	Texture(name:String, texture:BitmapData);
}
