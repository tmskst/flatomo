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
		
		var buildType = function (name:String, classPack:Array<String>, className:String):TypeDefinition {
			return {
				pack   : [],
				fields : [],
				name   : name,
				kind   : TypeDefKind.TDClass({ pack: classPack, name: className }),
				pos    : Context.currentPos(),
			};
		};
		var buildBitmapData = buildType.bind(_, ['flash', 'display'], 'BitmapData');
		var buildByteArray  = buildType.bind(_, ['flash', 'utils'], 'ByteArray');
		
		var addMetadata = function (metadata:String, path:String, className:String) {
			Compiler.addMetadata(metadata + '("' + path + '")', className);
		};
		var addMetadataBitmap = addMetadata.bind('@:bitmap', _, _);
		var addMetadataFile   = addMetadata.bind('@:file', _, _);
		
		
		var types:Array<TypeDefinition> = [];
		for (value in values) {
			// Texture
			var textureClassName:String = value.name + 'Texture';
			types.push(buildBitmapData(textureClassName));
			addMetadataBitmap(value.texture, textureClassName);
			
			// Xml
			var xmlClassName:String = value.name + 'Xml';
			types.push(buildByteArray(xmlClassName));
			addMetadataFile(value.xml, xmlClassName);
			
			// Pos
			var posClassName:String = value.name + 'Posture';
			types.push(buildByteArray(posClassName));
			addMetadataFile(value.posture, posClassName);
		}
		
		Context.defineModule('EmbedAsset', types);
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
