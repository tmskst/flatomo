package flatomo;

import flash.text.TextFormatAlign;
import flatomo.Posture;
import flatomo.translator.RawTextureAtlas;
import flatomo.display.Animation;
import flatomo.display.Container;
import flatomo.display.FlatomoImage;
import flatomo.display.FlatomoTextField;
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
	
	/** テクスチャアトラスとメタデータを元に FlatomoAssetManagerを生成する */
	public static function build(assetKit:AssetKit):GpuOperator {
		var atlases = new Array<TextureAtlas>();
		for (atlas in assetKit.atlases) {
			atlases.push(new TextureAtlas(Texture.fromBitmapData(atlas.image), atlas.layout));
		}
		return new GpuOperator(atlases, assetKit.postures);
	}
	
	public function new(atlases:Array<TextureAtlas>, postures:Map<ItemPath, Posture>) {
		this.manager = new AssetManager();
		for (index in 0...atlases.length) {
			var atlas = atlases[index];
			this.manager.addTextureAtlas('atlas${index}', atlas);
		}
		this.postures = postures;
	}
	
	private var manager:AssetManager;
	private var postures:Map<ItemPath, Posture>;
	
	/**
	 * クラス（Class<flash.display.DisplayObject>）に対応する
	 * 表示オブジェクト（starling.display.DisplayObject）を生成します
	 */
	public function createInstance(clazz:Class<flash.display.DisplayObject>):DisplayObject {
		return create("F:" + Type.getClassName(clazz), new Vector(0));
	}
	
	/**
	 * キー（ライブラリパス）を元に表示オブジェクトを生成します
	 * @param	key キー（ライブラリパス）
	 * @return 生成（構築）された表示オブジェクト
	 */
	// TODO : private
	public function create(key:String, layouts:Vector<Layout> = null):DisplayObject {
		if (layouts == null) { layouts = new Vector<Layout>(0); }
		
		var type = postures.get(key);
		switch (type) {
			/* Animation */
			case Posture.Animation(sections, pivotX, pivotY) :
				var textures = manager.getTextures(key);
				var animation = new Animation(layouts, textures, sections);
				animation.pivotX = pivotX;
				animation.pivotY = pivotY;
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
			case Posture.Image(pivotX, pivotY) :
				var image = new FlatomoImage(layouts, manager.getTexture(key));
				image.pivotX = pivotX;
				image.pivotY = pivotY;
				return image;
		}
	}
	
}
