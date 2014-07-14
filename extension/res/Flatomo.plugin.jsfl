var lastSymbol;

function getPluginInfo(lang)
{
//	fl.trace("==== getPluginInfo");
//	fl.trace(lang);
//	fl.trace("---- getPluginInfo");

	pluginInfo = new Object();
	pluginInfo.id = "Flatomo";
	pluginInfo.name = "Flatomo";
	pluginInfo.ext = "xml";
	pluginInfo.encoding = "utf8";
	pluginInfo.capabilities = new Object();
	pluginInfo.capabilities.canRotate = false;
	pluginInfo.capabilities.canTrim = true;
	pluginInfo.capabilities.canShapePad = true;
	pluginInfo.capabilities.canBorderPad = true;
	pluginInfo.capabilities.canStackDuplicateFrames = true;
	
	return pluginInfo;
}

function beginExport(meta)
{
//	fl.trace("==== endExport");
//	fl.trace(meta.app);
//	fl.trace(meta.version);
//	fl.trace(meta.image);
//	fl.trace(meta.format);
//	fl.trace(meta.size.w);
//	fl.trace(meta.size.h);
//	fl.trace(meta.scale);
//	fl.trace("---- endExport");

	var s = '<?xml version="1.0" encoding="utf-8"?>\n';
	s += '<TextureAtlas imagePath="' + meta.image + '">\n';
	s += '\t<!-- Created with ' + meta.app + ' version ' + meta.version + ' -->\n';
	s += '\t<!-- http://www.adobe.com/products/flash.html -->\n';

	lastSymbol = null;
	return s;
}

function frameExport(frame)
{
//	fl.trace("==== frameExport");
//	fl.trace(frame.id);
//	fl.trace(frame.frame.x);
//	fl.trace(frame.frame.y);
//	fl.trace(frame.frame.w);
//	fl.trace(frame.frame.h);
//	fl.trace(frame.offsetInSource.x);
//	fl.trace(frame.offsetInSource.y);
//	fl.trace(frame.sourceSize.w);
//	fl.trace(frame.sourceSize.h);
//	fl.trace(frame.rotated);
//	fl.trace(frame.trimmed);
//	fl.trace(frame.frameNumber);
//	fl.trace(frame.frameLabel);
//	fl.trace(frame.lastFrameLabel);
//	fl.trace("---- frameExport");

	var frameId = frame.id;
	if (frame.frameSource instanceof SymbolItem) {
		frameId = frame.frameSource.name;
		if (frame.frameSource.linkageExportForAS) {
			frameId = frame.frameSource.linkageClassName;
		}
	}
	
	var frameNumber = ('0000' + frame.frameNumber).slice(-4);
	
	var s = '\t<SubTexture name="' + frameId + frameNumber + '" x="' + frame.frame.x + '" y="' + frame.frame.y + '" width="' + frame.frame.w + '" height="' + frame.frame.h;
	
	if (frame.symbolName != lastSymbol) {
		lastSymbol = frame.symbolName;
		s += '" pivotX="' + frame.registrationPoint.x + '" pivotY="' + frame.registrationPoint.y;
	}
	
	if (frame.offsetInSource.x != 0 || frame.offsetInSource.y != 0 || frame.frame.w != frame.sourceSize.w || frame.frame.h != frame.sourceSize.h)
	{
		var srcofsx = 0 - frame.offsetInSource.x;
		var srcofsy = 0 - frame.offsetInSource.y;
		s += '" frameX="' + srcofsx + '" frameY="' + srcofsy + '" frameWidth="' + frame.sourceSize.w + '" frameHeight="' + frame.sourceSize.h;
	}
	s += '"/>\n';

	return  s;
}

function endExport(meta)
{
//	fl.trace("==== endExport");
//	fl.trace(meta.app);
//	fl.trace(meta.version);
//	fl.trace(meta.image);
//	fl.trace(meta.format);
//	fl.trace(meta.size.w);
//	fl.trace(meta.size.h);
//	fl.trace(meta.scale);
//	fl.trace("---- endExport");
	
	return '</TextureAtlas>\n';
}
