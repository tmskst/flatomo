package flatomo;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flatomo.display.Animation;
import flatomo.display.Container;
import flatomo.display.FlatomoImage;
import flatomo.util.StringMapUtil;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.AssetManager;

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
	 * キー（ライブラリパス）を元に表示オブジェクトを生成します
	 * @param	key キー（ライブラリパス）
	 * @return 生成（構築）された表示オブジェクト
	 */
	public function create(key:String, layouts:Array<Layout> = null):DisplayObject {
		if (layouts == null) { layouts = new Array<Layout>(); }
		
		var type = structures.get(key);
		switch (type) {
			/* Animation */
			case Structure.Animation :
				var textures = manager.getTextures(key);
				var animation = new Animation(layouts, textures);
				animation.touchable = false;
				return animation;
			/* Container */
			case Structure.Container(children) :
				var objects = new Array<DisplayObject>();
				for (child in children) {
					var object:DisplayObject = create(child.path, child.layouts);
					object.name = child.instanceName;
					object.touchable = false;
					objects.push(untyped object);
				}
				var container = new Container(layouts, objects);
				container.touchable = false;
				return container;
			/* Image */
			case Structure.Image(transform, _) :
				var image = new FlatomoImage(layouts, manager.getTexture(key), new Matrix(transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty));
				image.touchable = false;
				return image;
			/* PartsAnimation */
			case Structure.PartsAnimation(parts) :
				var objects = new Array<DisplayObject>();
				for (child in parts) {
					var object:DisplayObject = create(child.path, child.layouts);
					object.name = child.instanceName;
					object.touchable = false;
					objects.push(untyped object);
				}
				var container = new Container(layouts, objects);
				container.touchable = false;
				return container;
		}
	}
	
}
