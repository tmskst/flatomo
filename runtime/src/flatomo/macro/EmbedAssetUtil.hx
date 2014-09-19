package flatomo.macro;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.TypeDefinition;
import haxe.macro.Expr.TypeDefKind;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import sys.io.File;

private typedef Asset = {
	name:String,
	texture:String,
	xml:String,
	posture:String,
}

class EmbedAssetUtil {
	
	#if neko
	public static function run() {
		var assets:String = File.getContent(Context.definedValue('path'));
		var values:Array<Asset> = ExprTools.getValue(Context.parseInlineString(assets, Context.currentPos()));
		
		var buildType = function (name:String, pack:Array<String>, classPack:Array<String>, className:String):TypeDefinition {
			return {
				pack   : pack,
				fields : [],
				name   : name,
				kind   : TypeDefKind.TDClass({ pack: classPack, name: className }),
				pos    : Context.currentPos(),
			};
		};
		
		var buildBitmapData = buildType.bind(_, EmbedAsset.EMBED_ASSET_PACKAGE, ['flash', 'display'], 'BitmapData');
		var buildByteArray  = buildType.bind(_, EmbedAsset.EMBED_ASSET_PACKAGE, ['flash', 'utils'], 'ByteArray');
		
		var addMetadata = function (metadata:String, path:String, pack:Array<String>, className:String) {
			Compiler.addMetadata(metadata + '("' + path + '")', MacroStringTools.toDotPath(pack, className));
		};
		var addMetadataBitmap = addMetadata.bind('@:bitmap', _, EmbedAsset.EMBED_ASSET_PACKAGE, _);
		var addMetadataFile   = addMetadata.bind('@:file', _, EmbedAsset.EMBED_ASSET_PACKAGE, _);
		
		for (value in values) {
			// Texture
			var textureClassName:String = EmbedAsset.getTextureClassName(value.name);
			Context.defineType(buildBitmapData(textureClassName));
			addMetadataBitmap(value.texture, textureClassName);
			
			// Xml
			var xmlClassName:String = EmbedAsset.getXmlClassName(value.name);
			Context.defineType(buildByteArray(xmlClassName));
			addMetadataFile(value.xml, xmlClassName);
			
			// Pos
			var posClassName:String = EmbedAsset.getPostureClassName(value.name);
			Context.defineType(buildByteArray(posClassName));
			addMetadataFile(value.posture, posClassName);
		}
	}
	#end
	
	private static function buildEmbedAssetKey():Array<Field> {
		/*Context.definedValue('path')*/
		var file = File.getContent('assets.hx');
		var assets:Array<Asset> = ExprTools.getValue(Context.parseInlineString(file, Context.currentPos()));
		
		var buildField = function (name:String, value:String):Field {
			return {
				name     : name,
				access   : [Access.APublic, Access.AStatic],
				kind     : FieldType.FVar(
					ComplexType.TPath( { name : 'String', pack: [] } ),
					Context.parse('"' + value + '"', Context.currentPos())
				),
				pos      : Context.currentPos(),
			};
		};
		
		return [ for (asset in assets) buildField(asset.name, asset.name) ];
	}
	
}
