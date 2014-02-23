package flatomo;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.xml.XML;

using flatomo.AtlasGenerator;

private typedef Piece = { name:String, image:BitmapData };
private typedef Area = { name:String, rectangle:Rectangle };
private typedef Layer = { x:Int, y:Int, width:Int, height:Int };
private typedef TextureAtlas = { image:BitmapData, layout:Xml };

class AtlasGenerator {
	
	/** テクスチャアトラスを生成する */
	public static function generate(images:Array<{name:String, image:BitmapData}>):{ image:BitmapData, layout:Xml } {
		var LENGTHS = [64, 128, 256, 512, 1024, 2048, 4096];
		
		images.sort(function (a, b):Int {
			return Std.int(b.image.height - a.image.height);
		});
		var size:Int = 0;
		var areas:Array<Area> = null;
		for (length in LENGTHS) {
			var data = pack(images, length);
			if (data == null) { continue; }
			
			size = length;
			areas = data;
			break;
		}
		return generateTextureAtlas(images, areas, size);
	}
	
	/** テクスチャアトラスを生成する */
	@:noUsing
	private static function generateTextureAtlas(textures:Array<Piece>, areas:Array<Area>, size:Int):TextureAtlas {
		var canvas = new BitmapData(size, size, true, 0x00000000);
		var layout = Xml.createElement("TextureAtlas");
		layout.set("imagePath", "atlas.png");
		
		for (area in areas) {
			var subTexture = textures.findTexture(area.name);
			layout.addChild(createSubTextureElement(subTexture.name, area));
			canvas.blit(subTexture.image, area);
		}
		return { image: canvas, layout: layout };
	}
	
	/** テクスチャをアトラスに転写する */
	private static function blit(canvas:BitmapData, source:BitmapData, area:Area):Void {
		canvas.copyPixels(source, source.rect, new Point(area.rectangle.x, area.rectangle.y));
	}
	
	/** SubTexture要素を生成する */
	private static function createSubTextureElement(name:String, area:Area):Xml {
		var subTexture = Xml.createElement("SubTexture");
		subTexture.set("name", name);
		subTexture.set("x", Std.string(area.rectangle.x));
		subTexture.set("y", Std.string(area.rectangle.y));
		subTexture.set("width", Std.string(area.rectangle.width));
		subTexture.set("height", Std.string(area.rectangle.height));
		return subTexture;
	}
	
	/**
	 * 与えられた名前に対応するテクスチャを集合から探し出す
	 * @param	name
	 * @param	textures
	 * @return
	 */
	private static function findTexture(textures:Array<Piece>, name:String):Piece {
		for (texture in  textures) {
			if (texture.name == name) { return texture; }
		}
		throw 'SubTexture ${name} が見つかりません';
	}
	
	/**
	 * テクスチャを敷き詰める
	 * @param	pieces 名前を持ったテクスチャの集合
	 * @param	length テクスチャアトラス画像の一辺長さ
	 * @return テクスチャをどこに敷くかの対応関係の集合。敷き詰められなかった場合は nullが返される。
	 */
	@:noUsing
	private static function pack(pieces:Array<Piece>, length:Int):Null<Array<Area>> {
		// HFF ALGORITHM
		var layers = new Array<Layer>();
		var areas = new Array<Area>();
		for (piece in pieces) {
			var isNewLayer = false;
			for (layer in layers) {
				if (layer.x + piece.image.width <= length) {
					areas.push({ name: piece.name, rectangle: new Rectangle(layer.x, layer.y, piece.image.width, piece.image.height)} );
					layer.x = layer.x + piece.image.width;
					isNewLayer = true;
					break;
				}
			}
			if (!isNewLayer) {
				var lastLayer = if (layers.length != 0) layers[layers.length - 1] else { x: 0, y: 0, width: 0, height: 0 };
				var newLayer = { x: piece.image.width, y: lastLayer.y + lastLayer.height, width: piece.image.width, height: piece.image.height };
				if (newLayer.y + newLayer.height >= length) {
					return null;
				}
				areas.push({ name: piece.name, rectangle: new Rectangle(0, newLayer.y, piece.image.width, piece.image.height) });
				layers.push(newLayer);
			}
		}
		return areas;
	}
	
}
