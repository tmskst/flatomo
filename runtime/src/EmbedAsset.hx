package ;

#if flash
import flash.xml.XML;
import haxe.io.BytesData;
#end

#if !macro
@:build(flatomo.macro.EmbedAssetUtil.buildResolver())
#end
class EmbedAsset {
	
	@:resolver
	public static var resolver:Map<Asset, String>;
	
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static var EMBED_ASSET_PACKAGE:Array<String> = ['flatomo', 'macro', 'embedAsset'];
	
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static function getTextureClassName(className:String):String {
		return className + 'Texture';
	}
	
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static function getXmlClassName(className:String):String {
		return className + 'Xml';
	}
	
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static function getPostureClassName(className:String):String {
		return className + 'Posture';
	}
	
	private static function getClassPath(className:String):String { 
		return EMBED_ASSET_PACKAGE.join('.') + '.' + className;
	}
	
	#if flash
	
	/**
	 * キーに対応するテクスチャを返します
	 * ただしテクスチャの型は 'flash.display.BitmapData' または 'haxe.io.BytesData' です
	 */
	public static function getTexture(key:Asset):Dynamic {
		return Type.createInstance(Type.resolveClass(getClassPath(getTextureClassName(resolver.get(key)))), []);
	}
	
	/** キーに対応するXMLを返します */
	public static function getXml(key:Asset):XML {
		return new XML(Type.createInstance(Type.resolveClass(getClassPath(getXmlClassName(resolver.get(key)))), []));
	}
	
	
	#end
	
}
