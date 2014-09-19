package ;

@:allow(flatomo.macro.EmbedAssetUtil)
class EmbedAsset {
	
	private static var EMBED_ASSET_PACKAGE:Array<String> = ['flatomo', 'macro', 'embedAsset'];
	
	private static function getTextureClassName(className:String):String {
		return className + 'Texture';
	}
	
	private static function getXmlClassName(className:String):String {
		return className + 'Xml';
	}
	
	private static function getPostureClassName(className:String):String {
		return className + 'Posture';
	}
	
	private static function getClassPath(className:String):String { 
		return EMBED_ASSET_PACKAGE.join('.') + '.' + className;
	}
	
	public static function getTexture(key:String):Dynamic {
		return Type.createInstance(Type.resolveClass(getClassPath(getTextureClassName(key))), []);
	}
	
}
