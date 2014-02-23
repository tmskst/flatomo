package flatomo;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.Vector.Vector;
import flash.xml.XML;
import flatomo.Meta;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.AssetManager;

class FlatomoAssetManager {
	
	public static function build(atlas:{ atlas:BitmapData, layout:Xml, meta:Map<String, Meta> }):FlatomoAssetManager {
		return new FlatomoAssetManager(new TextureAtlas(Texture.fromBitmapData(atlas.atlas), new XML(atlas.layout.toString())), atlas.meta);
	}

	public function new(atlas:TextureAtlas, meta:Map<String, Meta>) {
		this.manager = new AssetManager();
		this.manager.addTextureAtlas("atlas", atlas);
		this.meta = meta;
	}
	
	private var manager:AssetManager;
	private var meta:Map<String, Meta>;
	
	@:access(flaotmo.Animation)
	public function createInstance(clazz:Class<flash.display.DisplayObject>):starling.display.DisplayObject {
		return create("F:" + Type.getClassName(clazz));
	}
	
	private function create(key:String):starling.display.DisplayObject {
		var type = meta.get(key);
		switch (type) {
			case Meta.Animation(sections) :
				var textures:Vector<Texture> = manager.getTextures(key);
				return new Animation(textures, sections);
			case Meta.Container(children, layouts, sections) :
				trace('Meta.Container # ${key}');
				var objects = new Array<starling.display.DisplayObject>();
				for (child in children) {
					var object = create(child.key);
					object.name = child.instanceName;
					
					objects.push(object);
				}
				return new Container(objects, layouts, sections);
			case Meta.Image :
				trace('Meta.Image # ${key}');
				return new Image(manager.getTexture(key));
		}
	}
	
}
