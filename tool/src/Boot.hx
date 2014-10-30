package ;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.PixelSnapping;
import flash.display.PNGEncoderOptions;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;
import flash.text.TextField;
import flatomo.GeometricTransform;
import flatomo.Structure;
import flatomo.Timeline;
import haxe.crypto.Sha1;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.PosInfos;
import haxe.Serializer;
import haxe.Unserializer;
import mcli.Dispatch;
import TextureAtlasGenerator;

using Lambda;
using flatomo.Collection;

private typedef U = {
	filePath:String,
	transform:GeometricTransform,
}

private typedef V = {
	resolver:Map<String, U>,
	required:Array<U>,
}

class Boot {
	
	public static function main() {
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, initialize);
	}
	
	private static var logger:TextField;
	
	private static function initialize(event:InvokeEvent) {
		logger = new TextField();
		logger.width  = Lib.current.stage.stageWidth;
		logger.height = Lib.current.stage.stageHeight;
		logger.selectable = true;
		Lib.current.stage.addChild(logger);
		
		switch (run(event)) {
			/* 入力に問題なし */
			case Successful :
				// 処理は非同期に終了する
			/* 何らかの例外が生じた */
			case v :
				log('例外 : ${v}');
		}
		
	}
	
	private static function log(message:String, ?posInfos:PosInfos):Void {
		logger.appendText('${posInfos.methodName} ${posInfos.lineNumber} : ${message} \n');
	}
	
	private static function run(event:InvokeEvent):ErrorCode {
		var cwd:File = event.currentDirectory;
		var apd:File = File.applicationDirectory;
		
		var args:Args = new Args();
		new Dispatch([for (v in event.arguments) v]).dispatch(args);
		
		// -o <output directory>
		if (args.output == null) {
			log('出力先が指定されていない');
			return ErrorCode.MissingArgumentOuput;
		}
		var output:File = cwd.resolvePath(args.output);
		
		// -i <input directory>
		var inputs = [for (input in args.inputs.keys()) cwd.resolvePath(input)];
		if (inputs.empty()) {
			log('入力が指定されていない');
			return ErrorCode.MissingArgumentInput;
		}
		
		// 入力として妥当ではないディレクトリの列挙
		var fails = inputs.filter(function (f) return !validate(f));
		if (!fails.empty()) {
			fails.iter(function (f) log('不正な入力 : ' + f.nativePath));
			return ErrorCode.InvaildArgumentInput;
		}
		
		// 引数はすべて妥当
		var unifiedStructures = unifyStructures(inputs);
		var unifiedTimelines = unifyTimelines(inputs);
		
		#if debug
		log('cwd -> ${cwd.nativePath}');
		log('apd -> ${apd.nativePath}');
		log('-o  -> ${output.nativePath}');
		inputs.iter(function (f) log('-i  -> ' + f.nativePath));
		log('- - -');
		for (key in unifiedStructures.keys()) { log('s -> ${key}, ${unifiedStructures.get(key)}'); }
		for (key in unifiedTimelines.keys()) { log('t -> ${key}'); }
		#end
		
		var uniquely = pruneDuplicateTexture(inputs);
		
		log('- - -');
		for (key in uniquely.resolver.keys()) { log('uniquely.resolver.key -> ${key}, ' + uniquely.resolver.get(key)); }
		
		scaleTexture(unifiedStructures, uniquely);
		loadRequiredTexture(uniquely, function(optimizedTextures:Map<U, Bitmap>) {
			log('- - -');
			
			var result = TextureAtlasGenerator.pack(uniquely.required.length, Lambda.array(optimizedTextures));
			if (result == null) { log('充填できなかった'); }
			
			var rootElement:Xml = Xml.createElement("TextureAtlas");
			
			for (key in unifiedStructures.keys()) {
				switch (unifiedStructures.get(key)) {
					case Structure.Animation(totalFrame, unionBounds) : 
						for (frame in 0...totalFrame) {
							var name:String = key + StringTools.lpad(Std.string(frame + 1), "0", 4);
							var unique:U = uniquely.resolver.get(name);
							var subTexture:SubTexture = optimizedTextures.get(unique);
							var region:Region = result.regions.get(subTexture);
							
							var element:Xml = Xml.createElement("SubTexture");
							element.set("name", name);
							element.set("x", Std.string(region.x));
							element.set("y", Std.string(region.y));
							element.set("width", Std.string(region.width));
							element.set("height", Std.string(region.height));
							
							var transform:GeometricTransform = unique.transform;
							log(Std.string(unionBounds));
							
							element.set("frameX", Std.string((unionBounds.left - transform.tx) * -1));
							element.set("frameY", Std.string((unionBounds.top - transform.ty) * -1));
							element.set("frameWidth", Std.string(unionBounds.right - unionBounds.left));
							element.set("frameHeight", Std.string(unionBounds.bottom - unionBounds.top));
							rootElement.addChild(element);
						}
					case Structure.Image(transform, bounds) :
						var name:String = key;
						var unique:U = uniquely.resolver.get(name);
						var subTexture:SubTexture = optimizedTextures.get(unique);
						var region:Region = result.regions.get(subTexture);
						
						var element:Xml = Xml.createElement("SubTexture");
						element.set("name", name);
						element.set("x", Std.string(region.x));
						element.set("y", Std.string(region.y));
						element.set("width", Std.string(region.width));
						element.set("height", Std.string(region.height));
						
						transform.a = unique.transform.a;
						transform.b = unique.transform.b;
						transform.c = unique.transform.c;
						transform.d = unique.transform.d;
						transform.tx = unique.transform.tx;
						transform.ty = unique.transform.ty;
						
						rootElement.addChild(element);
					case Structure.Container(_) :
					case Structure.PartsAnimation(_) :
						
				}
			}
			
			FileUtil.saveContent(output.resolvePath('./a.xml'), rootElement.toString());
			FileUtil.saveContent(output.resolvePath('./a.structure'), Serializer.run(unifiedStructures));
			FileUtil.saveContent(output.resolvePath('./a.timeline'), Serializer.run(unifiedTimelines));
			
			// 充填
			
			var texture:BitmapData = new BitmapData(result.size, result.size, true, 0x00000000);
			for (subTexture in result.regions.keys()) {
				var region:Region = result.regions.get(subTexture);
				var bitmap:Bitmap = cast subTexture;
				texture.copyPixels(bitmap.bitmapData, bitmap.bitmapData.rect, new Point(Math.floor(region.x + 1), Math.floor(region.y + 1)));
			}
			FileUtil.saveBytes(output.resolvePath('./a.png'), texture.encode(texture.rect, new PNGEncoderOptions()));
			
			log("終了");
		});
		
		return ErrorCode.Successful;
	}
	
	/** 重複したテクスチャをそぎ落とす */
	private static function pruneDuplicateTexture(inputs:Array<File>):V {
		var files:Array<File> = cast inputs
			.map(function (f) return f.resolvePath('./texture/'))
			.map(function (f) return readDirectoryRecursive(f))
			.flatten();
		
		var fromItem = new Map<String, U>();
		var fromHash = new Map<String, U>();
		
		for (file in files) {
			var hash:String = Sha1.make(FileUtil.getBytes(file)).toHex();
			
			#if debug
			if (fromHash.exists(hash)) {
				log('duplicate -> ' + fromHash.get(hash).filePath + ', ' + file.nativePath);
			}
			#end
			
			if (!fromHash.exists(hash)) {
				fromHash.set(hash, { 
					filePath  : file.nativePath,
					transform : { a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0 },
				});
			}
			var delegate = fromHash.get(hash);
			fromItem.set(getNativePathWithoutExtension(file), delegate);
		}
		
		return {
			resolver : fromItem,
			required : Lambda.array(fromHash),
		};
	}
	
	/** テクスチャを必要とされている最大の大きさに縮小する */
	private static function scaleTexture(unifiedStructures:Map<String, Structure>, uniquely:V):Void {
		// TODO : 改善可能
		for (key in unifiedStructures.keys()) {
			switch (unifiedStructures.get(key)) {
				case PartsAnimation(children) :
					for (child in children) {
						var transform = uniquely.resolver.get(child.path).transform;
						for (layout in child.layouts) {
							if (layout != null) {
								var scaleX:Float = Math.sqrt(layout.transform.a * layout.transform.a + layout.transform.b * layout.transform.b);
								var scaleY:Float = Math.sqrt(layout.transform.c * layout.transform.c + layout.transform.d * layout.transform.d);
								transform.a = Math.min(Math.max(transform.a, scaleX), 1.0);
								transform.d = Math.min(Math.max(transform.d, scaleY), 1.0);
							}
						}
					}
				case Container(children) :
					for (child in children) {
						var transform = uniquely.resolver.get(child.path).transform;
						for (layout in child.layouts) {
							transform.a = 1.0;
							transform.d = 1.0;
						}
					}
				case Animation(totalFrames, _) :
					switch (totalFrames) {
						case 1 : 
							var transform = uniquely.resolver.get(key).transform;
							transform.a = 1.0;
							transform.d = 1.0;
						case _ :
							for (index in 0...totalFrames) {
								var path:String = key + StringTools.lpad(Std.string(index + 1), '0', 4);
								var transform = uniquely.resolver.get(path).transform;
								transform.a = 1.0;
								transform.d = 1.0;
							}
					}
				case Image(_) :
					
			}
		}
	}
	
	private static function loadRequiredTexture(uniquely:V, callback:Map<U, Bitmap> -> Void):Void {
		var length = uniquely.required.length;
		var loadCompleted = [for (i in 0...length) false];
		
		var optimizedTextures = new Map<U, Bitmap>(); 
		
		for (index in 0...length) {
			var texture = uniquely.required[index];
			
			var bytes = FileUtil.getBytes(new File(texture.filePath));
			var loader = new Loader();
			loader.loadBytes(bytes.getData());
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event) {
				var image = new BitmapData(Std.int(loader.width), Std.int(loader.height), true, 0x00000000);
				image.draw(loader);
				var optimized = trimTransparent(texture, image);
				optimizedTextures.set(texture, optimized);
				
				loadCompleted[index] = true;
				if (loadCompleted.fold(function (a, b) return a && b, true)) {
					callback(optimizedTextures);
				}
			});
		}
	}
	
	private static function trimTransparent(uniquely:U, image:BitmapData):Bitmap {
		var bounds = image.getColorBoundsRect(0xFF000000, 0x00000000, false);
		uniquely.transform.tx = uniquely.transform.tx - bounds.x;
		uniquely.transform.ty = uniquely.transform.ty - bounds.y;
		
		var trimmed = new BitmapData(Std.int(bounds.width), Std.int(bounds.height), true, 0x00000000);
		trimmed.copyPixels(image, bounds, new Point(0, 0));
		
		var u = uniquely.transform;
		
		var translation  = new Matrix(1, 0, 0, 1, u.tx, u.ty);
		var scaling      = new Matrix(u.a, 0, 0, u.d, 0, 0);
		
		var concatenated = new Matrix(1, 0, 0, 1, 0, 0);
		concatenated.concat(translation);
		concatenated.concat(scaling);
		
		var bitmap = new Bitmap(trimmed, PixelSnapping.AUTO, false);
		bitmap.transform.matrix = concatenated;
		
		uniquely.transform.a  = concatenated.a;
		uniquely.transform.b  = concatenated.b;
		uniquely.transform.c  = concatenated.c;
		uniquely.transform.d  = concatenated.d;
		uniquely.transform.tx = concatenated.tx;
		uniquely.transform.ty = concatenated.ty;
		
		log(Std.string(uniquely.filePath));
		log('${bitmap.width}, ${bitmap.height}');
		var optimized = new Bitmap(new BitmapData(Std.int(bitmap.width), Std.int(bitmap.height), true, 0x00000000));
		optimized.bitmapData.draw(bitmap, scaling);
		
		return optimized;
	}
	
	/** 各々のライブラリが出力した構造情報のマップを1つにまとめる */
	private static function unifyStructures(inputs:Array<File>):Map<String, Structure> {
		var readStructures:File -> Map<String, Structure> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.structure')));
		};
		
		var unifiedStructures = new Map<String, Structure>();
		for (directory in inputs) {
			var structures:Map<String, Structure> = readStructures(directory);
			for (key in structures.keys()) {
				var structure:Structure = structures.get(key);
				switch (structure) {
					case Container(children) | PartsAnimation(children) : 
						for (child in children) {
							child.path = resolvePath(directory, child.path);
						}
					case _ : 
						
				}
				unifiedStructures.set(resolvePath(directory, key), structure);
			}
		}
		
		return unifiedStructures;
	}
	
	/** 各々のライブラリが出力したタイムラインのマップを1つにまとめる */
	private static function unifyTimelines(inputs:Array<File>):Map<String, Timeline> {
		var readTimelines:File -> Map<String, Timeline> = function (directory:File) {
			return Unserializer.run(FileUtil.getContent(directory.resolvePath('./a.timeline')));
		};
		
		var unifiedTimelines = new Map<String, Timeline>();
		for (directory in inputs) {
			var timelines:Map<String, Timeline> = readTimelines(directory);
			for (key in timelines.keys()) {
				unifiedTimelines.set(resolvePath(directory, key), timelines.get(key));
			}
		}
		return unifiedTimelines;
	}
	
	// ユーティリティ
	// //////////////////////////////////////////////////////////////
	
	/** 拡張子を除いた'File.nativePath'を取得する */
	private static function getNativePathWithoutExtension(file:File):String {
		return file.nativePath.substring(0, file.nativePath.lastIndexOf('.'));
	}
	
	private static function resolvePath(directory:File, key:String):String {
		return directory.resolvePath('./texture/').resolvePath(key).nativePath;
	}	
	
	/** 対象のディレクトリが入力になり得るか */
	private static function validate(directory:File):Bool {
		return directory.isDirectory
		    && directory.resolvePath('a.timeline').exists
		    && directory.resolvePath('a.structure').exists
		    && directory.resolvePath('src').isDirectory
		    && directory.resolvePath('texture').isDirectory;
	}
	
	/** 指定したディレクトリの子を再帰的に走査し子の一覧を返す */
	private static function readDirectoryRecursive(root:File):Array<File> {
		var children:Array<File> = [];
		for (child in root.getDirectoryListing()) {
			if (child.isDirectory) {
				children = children.concat(readDirectoryRecursive(child));
			} else {
				children.push(child);
			}
		}
		return children;
	}
	
}
