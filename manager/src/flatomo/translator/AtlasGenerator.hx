package flatomo.translator;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.xml.XML;

using Lambda;
using flatomo.translator.AtlasGenerator;

/** テクスチャを敷く領域 */
private typedef Area = {
	var name:String;
	var rectangle:Rectangle;
};

/** 充填計算用 */
private typedef Layer = {
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
};

class AtlasGenerator {
	
	/** テクスチャアトラスを生成する */
	public static function generate(images:Array<RawTexture>):Array<RawTextureAtlas> {
		var lengths = [64, 128, 256, 512, 1024, 2048];
		images.sort(function (a, b):Int {
			return Std.int(b.image.height - a.image.height);
		});
		var packedNameList = new List<String>();
		var v = new Array<{ areas:Array<Area>, imageSize:Int }>();
		
		while (packedNameList.length < images.length) {
			var areas:Array<Area> = null;
			var imageSize:Int = 0;
			for (length in lengths) {
				areas = pack(images, length, packedNameList);
				imageSize = length;
				if (packedNameList.length + areas.length == images.length) { break; }
			}
			for (area in areas) {
				packedNameList.add(area.name);
			}
			v.push( { areas: areas, imageSize: imageSize } );
		}
		
		var atlases = new Array<RawTextureAtlas>();
		for (n in v) {
			atlases.push(generateTextureAtlas(images, n.areas, n.imageSize));
		}
		return atlases;
	}
	
	/** テクスチャアトラスを生成する */
	@:noUsing
	private static function generateTextureAtlas(textures:Array<RawTexture>, areas:Array<Area>, size:Int):RawTextureAtlas {
		var canvas = new BitmapData(size, size, true, 0x00000000);
		var layout = Xml.createElement("TextureAtlas");
		layout.set("imagePath", "atlas.png");
		
		for (area in areas) {
			var subTexture = textures.findTexture(area.name);
			layout.addChild(createSubTextureElement(subTexture, area));
			canvas.blit(subTexture.image, area);
		}
		return { image: canvas, layout: new flash.xml.XML(layout.toString()) };
	}
	
	/** テクスチャをアトラスに転写する */
	private static function blit(canvas:BitmapData, source:BitmapData, area:Area):Void {
		canvas.copyPixels(source, source.rect, new Point(area.rectangle.x, area.rectangle.y));
	}
	
	/** SubTexture要素を生成する */
	private static function createSubTextureElement(piece:RawTexture, area:Area):Xml {
		var subTexture = Xml.createElement("SubTexture");
		subTexture.set("name", piece.name);
		subTexture.set("x", Std.string(area.rectangle.x));
		subTexture.set("y", Std.string(area.rectangle.y));
		subTexture.set("width", Std.string(area.rectangle.width));
		subTexture.set("height", Std.string(area.rectangle.height));
		if (piece.frame != null) {
			subTexture.set("frameX", Std.string(piece.frame.x));
			subTexture.set("frameY", Std.string(piece.frame.y));
			subTexture.set("frameWidth", Std.string(piece.frame.width));
			subTexture.set("frameHeight", Std.string(piece.frame.height));
		}
		if (piece.index == 0) {
			subTexture.set("pivotX", Std.string( -piece.unionBounds.x));
			subTexture.set("pivotY", Std.string( -piece.unionBounds.y));
		}
		return subTexture;
	}
	
	/**
	 * 与えられた名前に対応するテクスチャを集合から探し出す
	 * @param	name
	 * @param	textures
	 * @return
	 */
	private static function findTexture(textures:Array<RawTexture>, name:String):RawTexture {
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
	private static function pack(pieces:Array<RawTexture>, length:Int, packedNameList:List<String>, ?padding:Int = 2):Array<Area> {
		// HFF ALGORITHM
		var layers = new Array<Layer>();
		var areas = new Array<Area>();
		for (piece in pieces) {
			if (packedNameList.exists(function (p) { return p == piece.name; } )) { continue; }
			var isNewLayer = false;
			for (layer in layers) {
				if (layer.x + piece.image.width + padding <= length) {
					areas.push({ name: piece.name, rectangle: new Rectangle(layer.x, layer.y, piece.image.width, piece.image.height)} );
					layer.x = layer.x + piece.image.width + padding;
					isNewLayer = true;
					break;
				}
			}
			if (!isNewLayer) {
				var lastLayer = if (layers.length != 0) layers[layers.length - 1] else { x: 0, y: 0, width: 0, height: 0 };
				var newLayer = { x: piece.image.width + padding, y: lastLayer.y + lastLayer.height + padding, width: piece.image.width, height: piece.image.height };
				if (newLayer.y + newLayer.height < length) {
					areas.push({ name: piece.name, rectangle: new Rectangle(0, newLayer.y, piece.image.width, piece.image.height) });
					layers.push(newLayer);
				}
			}
		}
		return areas;
	}
	
}
