package ;
import flatomo.ItemPath;
import flatomo.Section;
import flatomo.Structure;
import flatomo.Timeline;
import haxe.Unserializer;

#if flash
import flash.xml.XML;
import haxe.io.BytesData;
#end

#if !macro
@:build(flatomo.macro.EmbedAssetUtil.buildResolver())
#end
class EmbedAsset {
	
	/* アセットから埋め込みアセットのクラス名を解決するために使われる */
	@:resolver
	public static var resolver:Map<Asset, String>;
	
	/* 埋め込みアセットのクラスの出力先パッケージ */
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static var EMBED_ASSET_PACKAGE:Array<String> = ['flatomo', 'macro', 'embedAsset'];
	
	/* アセット名から埋め込みテクスチャのクラス名を取得する */
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static inline function getTextureClassName(assetName:String):String {
		return assetName + 'Texture';
	}
	
	/* アセット名から埋め込みXMLのクラス名を取得する */
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static inline function getXmlClassName(assetName:String):String {
		return assetName + 'Xml';
	}
	
	/* アセット名から埋め込みストラクチャのクラス名を取得する */
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static inline function getStructureClassName(assetName:String):String {
		return assetName + 'Structure';
	}
	
	/* アセット名から埋め込みタイムラインのクラス名を取得する */
	@:allow(flatomo.macro.EmbedAssetUtil)
	private static inline function getTimelineClassName(assetName:String):String {
		return assetName + 'Timeline';
	}
	
	/* 埋め込みアセットのクラスの完全修飾名を取得する */
	private static function getClassPath(className:String):String { 
		return EMBED_ASSET_PACKAGE.join('.') + '.' + className;
	}
	
	#if flash
	
	/* クラス名を元にインスタンスを生成するヘルパメソッド */
	private static inline function createInstance(className:String):Dynamic {
		return Type.createInstance(Type.resolveClass(className), []);
	}
	
	/** キーに対応するテクスチャのクラスを返します */
	public static function getTextureClass(key:Asset):Class<Dynamic> {
		return Type.resolveClass(getClassPath(getTextureClassName(resolver.get(key))));
	}
	
	/** キーに対応するXMLを返します */
	public static function getXml(key:Asset):XML {
		return new XML(createInstance(getClassPath(getXmlClassName(resolver.get(key)))));
	}
	
	public static function getStructure(key:Asset):Map<ItemPath, Structure> {
		return haxe.Unserializer.run(createInstance(getClassPath(getStructureClassName(resolver.get(key)))));
	}
	
	public static function getTimeline(key:Asset):Map<String, Timeline> {
		return haxe.Unserializer.run(createInstance(getClassPath(getTimelineClassName(resolver.get(key)))));
	}
	
	#end
	
}
