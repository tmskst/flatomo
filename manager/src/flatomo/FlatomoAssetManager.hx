package flatomo;
import flash.display.BitmapData;
import flash.xml.XML;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.AssetManager;

class FlatomoAssetManager {
	
	public static function build(source:{image:BitmapData, layout:XML, metaData:Map<String, Meta>}):FlatomoAssetManager {
		var texture = Texture.fromBitmapData(source.image);
		return new FlatomoAssetManager(new TextureAtlas(texture, source.layout), source.metaData);
	}
	
	public function new(atlas:TextureAtlas, meta:Map<String, Meta>) {
		this.manager = new AssetManager();
		this.manager.addTextureAtlas("atlas", atlas);
		this.meta = meta;
	}
	
	private var manager:AssetManager;
	private var meta:Map<String, Meta>;
	
	/**
	 * クラス（Class<flash.display.DisplayObject>）に対応する
	 * 表示オブジェクト（starling.display.DisplayObject）を生成します
	 */
	public function createInstance(clazz:Class<flash.display.DisplayObject>):DisplayObject {
		return create("F:" + Type.getClassName(clazz));
	}
	
	/**
	 * キー（ライブラリパス）を元に表示オブジェクトを生成します
	 */
	private function create(key:String):DisplayObject {
		var type = meta.get(key);
		switch (type) {
			case Meta.Animation(sections) :
				var textures = manager.getTextures(key);
				return new Animation(textures, sections);
			case Meta.Container(children, layouts, sections) :
				var objects = new Array<DisplayObject>();
				for (child in children) {
					var object = create(child.key);
					object.name = child.instanceName;
					objects.push(object);
				}
				return new Container(objects, layouts, sections);
			case Meta.Image :
				return new Image(manager.getTexture(key));
		}
	}
	
}
