package flatomo;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.xml.XML;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class AtlasGenerator{
	
	public static function generate(mints:Array<Mint>):TextureAtlas {
		var LENGTHS = [64, 128, 256, 512, 1024, 2048, 4096];
		
		mints.sort(function (a:Mint, b:Mint):Int {
			return Std.int(b.bitmapData.height - a.bitmapData.height);
		});
		var size:Int = 0;
		var atlas:Array<Area> = null;
		for (length in LENGTHS) {
			var data = pack(mints, length);
			if (data == null) { continue; }
			
			atlas = data;
			size = length;
			break;
		}
		return genAtlas(size, mints, atlas);
	}
	
	private static function genAtlas(size:Int, textures:Array<Mint>, areas:Array<Area>):TextureAtlas {
		var canvas = new BitmapData(size, size, true, 0x00000000);
		var atlas:Xml = Xml.createElement("TextureAtlas");
		atlas.set("imagePath", "atlas.png");
		
		for (area in areas) {
			var subTexture:Mint = findTexture(area.name, textures);
			var info:Xml = Xml.createElement("SubTexture");
			info.set("name", subTexture.name);
			info.set("x", Std.string(area.rectangle.x));
			info.set("y", Std.string(area.rectangle.y));
			info.set("width", Std.string(area.rectangle.width));
			info.set("height", Std.string(area.rectangle.height));
			atlas.addChild(info);
			
			canvas.copyPixels(subTexture.bitmapData, subTexture.bitmapData.rect, new Point(area.rectangle.x, area.rectangle.y));
		}
		return new TextureAtlas(Texture.fromBitmapData(canvas), new XML(atlas.toString()));
	}
	
	private static function findTexture(name:String, textures:Array<Mint>):Mint {
		for (texture in  textures) {
			if (texture.name == name) {
				return texture;
			}
		}
		throw 'SubTexture ${name} Not Found';
	}	
	private static function pack(mints:Array<Mint>, length:Int):Array<Area> {
		// HFF ALGORITHM
		var layers = new Array<Layer>();
		var areas = new Array<Area>();
		for (texture in mints) {
			var isNewLayer = false;
			for (layer in layers) {
				if (layer.x + texture.bitmapData.width <= length) {
					areas.push({ name: texture.name, rectangle: new Rectangle(layer.x, layer.y, texture.bitmapData.width, texture.bitmapData.height)} );
					layer.x = layer.x + texture.bitmapData.width;
					isNewLayer = true;
					break;
				}
			}
			if (!isNewLayer) {
				var lastLayer = if (layers.length != 0) layers[layers.length - 1] else { x: 0, y: 0, width: 0, height: 0 };
				var newLayer = { x: texture.bitmapData.width, y: lastLayer.y + lastLayer.height, width: texture.bitmapData.width, height: texture.bitmapData.height };
				if (newLayer.y + newLayer.height >= length) {
					return null;
				}
				areas.push({ name: texture.name, rectangle: new Rectangle(0, newLayer.y, texture.bitmapData.width, texture.bitmapData.height) });
				layers.push(newLayer);
			}
		}
		return areas;
	}
	
	
}

typedef Mint = {
	var name:String;
	var bitmapData:BitmapData;
}

private typedef Area = {
	var name:String;
	var rectangle:Rectangle;
}

private typedef Layer = {
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
}