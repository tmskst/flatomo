package flatomo.util;

import flash.display.BitmapData;
import flash.utils.ByteArray;
import flash.xml.XML;

enum EmbedTextureAtlas {
	BitmapData(image:Class<BitmapData>, layout:Class<ByteArray>);
	Atf(image:Class<ByteArray>, layout:Class<ByteArray>);
}
