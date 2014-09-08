package flatomo;

import flash.geom.Point;
import flash.text.TextFormatAlign;
import flash.xml.XML;
import flash.xml.XMLList;
import flatomo.display.Animation;
import flatomo.display.Container;
import flatomo.display.FlatomoImage;
import flatomo.display.FlatomoTextField;
import flatomo.Posture;
import haxe.ds.Vector;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.AssetManager;
import starling.utils.HAlign;
import starling.utils.VAlign;

class GpuOperator {
	
	/**
	 * AssetKitを元にGpuOperatorを初期化する。
	 * @param	assetKit 
	 */
	
	public function new(assetKit:AssetKit) {
		this.postures = assetKit.postures;
		this.manager = new AssetManager();
		
		// テクスチャアトラスの生成
		for (index in 0...assetKit.atlases.length) {
			var rawTextureAtlas:RawTextureAtlas = assetKit.atlases[index];
			var textureAtlas:TextureAtlas = switch (rawTextureAtlas) {
				case RawTextureAtlas.BitmapData(image, layout) :
					new TextureAtlas(Texture.fromBitmapData(image), layout);
				case RawTextureAtlas.Atf(image, layout) : 
					new TextureAtlas(Texture.fromAtfData(image), layout);
			};
			
			manager.addTextureAtlas('ATLAS' + index, textureAtlas);
		}
		
		
		this.pivots = new Map<String, Point>();
		// スプライトシートからpivotに関する情報を抜き出す
		for (rawTextureAtlas in assetKit.atlases) {
			switch(rawTextureAtlas) {
				case RawTextureAtlas.BitmapData(_, layout)
				|	 RawTextureAtlas.Atf(_, layout) :
					var subTextures:XMLList = layout.elements("SubTexture");
					for (index in 0...subTextures.length()) {
						var subTexture:XML = subTextures[index];
						var pivotX:Float = Std.parseFloat(subTexture.attribute("pivotX").toString());
						var pivotY:Float = Std.parseFloat(subTexture.attribute("pivotY").toString());
						if (!Math.isNaN(pivotX) && !Math.isNaN(pivotY)) {
							var key:String = subTexture.attribute("name").toString();
							// FIXME : 本来は Animation, Image関係なくサフィックス`0000`は付く
							if (StringTools.endsWith(key, "0000")) {
								key = key.substr(0, -4);
							}
							pivots.set(key, new Point(pivotX, pivotY));
						}
					}
			}
		}
	}
	
	private var manager:AssetManager;
	private var postures:Map<ItemPath, Posture>;
	private var pivots:Map<ItemPath, Point>;
	
	
	/**
	 * クラス（Class<flash.display.DisplayObject>）に対応する
	 * 表示オブジェクト（starling.display.DisplayObject）を生成します
	 */
	public function createInstance(clazz:Class<flash.display.DisplayObject>):DisplayObject {
		return create("F:" + Type.getClassName(clazz), new Array<Layout>());
	}
	
	/**
	 * キー（ライブラリパス）を元に表示オブジェクトを生成します
	 * @param	key キー（ライブラリパス）
	 * @return 生成（構築）された表示オブジェクト
	 */
	// TODO : private
	public function create(key:String, layouts:Array<Layout> = null):DisplayObject {
		if (layouts == null) { layouts = new Array<Layout>(); }
		
		var type = postures.get(key);
		switch (type) {
			/* Animation */
			case Posture.Animation(_) :
				var textures = manager.getTextures(key);
				var animation = new Animation(layouts, textures);
				var pivot = pivots.get(key);
				animation.pivotX = pivot.x;
				animation.pivotY = pivot.y;
				return animation;
			/* Container */
			case Posture.Container(children, sections) :
				var objects = new Array<DisplayObject>();
				for (instanceName in children.keys()) {
					var child = children.get(instanceName);
					var object = create(child.path, child.layouts);
					object.name = instanceName;
					objects.push(object);
				}
				return new Container(layouts, objects, sections);
			/* TextField */
			case Posture.TextField(width, height, text, textFormat) : 
				var textField = new FlatomoTextField(layouts, width, height, text, textFormat.font, textFormat.size, textFormat.color, textFormat.bold);
				textField.vAlign = VAlign.TOP;
				textField.hAlign = switch (textFormat.align) {
					case TextFormatAlign.CENTER	: HAlign.CENTER;
					case TextFormatAlign.LEFT	: HAlign.LEFT;
					case TextFormatAlign.RIGHT	: HAlign.RIGHT;
				};
				return textField;
			/* Image */
			case Posture.Image :
				var image = new FlatomoImage(layouts, manager.getTexture(key));
				var pivot = pivots.get(key);
				image.pivotX = pivot.x;
				image.pivotY = pivot.y;
				return image;
		}
	}
	
}
