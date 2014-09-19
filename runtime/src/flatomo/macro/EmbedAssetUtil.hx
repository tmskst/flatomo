package flatomo.macro;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.TypeDefinition;
import haxe.macro.Expr.TypeDefKind;
import haxe.macro.ExprTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Printer;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import sys.io.File;

using Lambda;

class EmbedAssetUtil {
	
	private static function getStaticFields():Array<ClassField> {
		var classPath:String = Context.definedValue('path');
		var type:Type = Context.getType(classPath);
		return TypeTools.getClass(type).statics.get();
	}
	
	#if neko
	public static function run() {
		var staticFields:Array<ClassField> = getStaticFields();
		var getAsset:ClassField -> { name:String, asset:Asset } = function (field) {
			return { name: field.name, asset: ExprTools.getValue(Context.getTypedExpr(field.expr())) };
		};
		
		var values = staticFields.map(getAsset);
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
			addMetadataBitmap(value.asset.texture, textureClassName);
			
			// Xml
			var xmlClassName:String = EmbedAsset.getXmlClassName(value.name);
			Context.defineType(buildByteArray(xmlClassName));
			addMetadataFile(value.asset.xml, xmlClassName);
			
			// Pos
			var posClassName:String = EmbedAsset.getPostureClassName(value.name);
			Context.defineType(buildByteArray(posClassName));
			addMetadataFile(value.asset.posture, posClassName);
		}
		
	}
	
	public static function buildResolver():Array<Field> {
		var getAssetName:ClassField -> String = function (field) {
			return field.name;
		};
		
		var assets = getStaticFields().map(getAssetName);
		
		var context = new StringBuf();
		{
			context.add("[");
			for (asset in assets) {
				context.add(Context.definedValue('path') + "." + asset + "=>" + "'" + asset + "',");
			}
			context.add("]");
		}
		
		var resolver = Context.parseInlineString(context.toString(), Context.currentPos());
		
		var fields = Context.getBuildFields();
		for (field in fields) {
			switch (field) {
				case { meta : [ { name: ':resolver' } ], kind : FieldType.FVar(t, e) } :
					field.kind = FVar(t, resolver);
				case _ :
			}
		}
		return fields;
	}
	
	#end
	
}
