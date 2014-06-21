var lastSymbol;

function getPluginInfo(lang)
{
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
	var s = '<?xml version="1.0" encoding="utf-8"?>\n';
	s += '<TextureAtlas imagePath="' + meta.image + '">\n';
	s += '\t<!-- Created with ' + meta.app + ' version ' + meta.version + ' -->\n';
	s += '\t<!-- http://www.adobe.com/products/flash.html -->\n';

	lastSymbol = null;
	return s;
}

function frameExport(frame)
{
	var frameId = frame.id;
	if (frame.frameSource instanceof SymbolItem) {
		frameId = frame.frameSource.linkageClassName;
	}
	
	var s = '\t<SubTexture name="' + frameId + frame.frameNumber + '" x="' + frame.frame.x + '" y="' + frame.frame.y + '" width="' + frame.frame.w + '" height="' + frame.frame.h;
	
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
	return '</TextureAtlas>\n';
}
