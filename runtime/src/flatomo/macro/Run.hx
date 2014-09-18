package flatomo.macro;

import haxe.macro.Compiler;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import sys.io.File;

class Run {
	
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
}
