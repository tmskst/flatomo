package flatomo;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextFormatAlign;
import flash.xml.XML;
import flash.xml.XMLList;
import flatomo.display.Animation;
import flatomo.display.Container;
import flatomo.display.FlatomoImage;
import flatomo.display.FlatomoTextField;
import flatomo.util.StringMapUtil;
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
	
	public function new() {
		this.manager = new AssetManager();
		this.structures = new Map<ItemPath, Structure>();
	}
	
	public function addEmbedAsset(asset:Asset):Void {
		
		var clazz = EmbedAsset.getTextureClass(asset);
		var superClass = Type.getSuperClass(clazz);
		
		var texture:Texture = if (superClass == flash.display.BitmapData) {
			Texture.fromBitmapData(Type.createInstance(clazz, []));
		} else {
			Texture.fromAtfData(Type.createEmptyInstance(clazz));
		}
		
		var xml = EmbedAsset.getXml(asset);
		
		var name:String = EmbedAsset.resolver.get(asset);
		manager.addTextureAtlas(name, new TextureAtlas(texture, xml));
		
		structures = StringMapUtil.unite([structures, EmbedAsset.getStructure(asset)]);
	}
	
	private var manager:AssetManager;
	private var structures:Map<ItemPath, Structure>;
	
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
	public function create(key:String, layouts:Array<Layout> = null):Dynamic {
		if (layouts == null) { layouts = new Array<Layout>(); }
		trace(key);
		var type = structures.get(key);
		switch (type) {
			/* Animation */
			case Structure.Animation :
				var textures = manager.getTextures(key);
				var animation = new Animation(layouts, textures);
				return animation;
			/* Container */
			case Structure.Container(children) :
				var objects = new Array<DisplayObject>();
				for (child in children) {
					var object = create(child.path, child.layouts);
					object.name = child.instanceName;
					objects.push(untyped object);
				}
				return new Container(layouts, objects);
			/* TextField */
			/*
			case Posture.TextField(width, height, text, textFormat) : 
				var textField = new FlatomoTextField(layouts, width, height, text, textFormat.font, textFormat.size, textFormat.color, textFormat.bold);
				textField.vAlign = VAlign.TOP;
				textField.hAlign = switch (textFormat.align) {
					case TextFormatAlign.CENTER	: HAlign.CENTER;
					case TextFormatAlign.LEFT	: HAlign.LEFT;
					case TextFormatAlign.RIGHT	: HAlign.RIGHT;
				};
				return textField;
			*/
			/* Image */
			case Structure.Image(transform, _) :
				var image = new FlatomoImage(layouts, manager.getTexture(key), new Matrix(transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty));
				return image;
			case Structure.PartsAnimation(parts) :
				var objects = new Array<DisplayObject>();
				for (child in parts) {
					var object = create(child.path, child.layouts);
					object.name = child.instanceName;
					objects.push(untyped object);
				}
				return new Container(layouts, objects);
		}
	}
	
}
