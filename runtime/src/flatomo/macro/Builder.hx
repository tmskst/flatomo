package flatomo.macro;

import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.ExprTools;
import sys.io.File;

class Builder {
	
	public static function build():Array<Field> {
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
