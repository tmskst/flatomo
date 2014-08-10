package flatomo.translator;

import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.xml.XML;

enum RawTextureAtlas {
	BitmapData(image:BitmapData, layout:XML);
	Atf(image:ByteArray, layout:XML);
}
