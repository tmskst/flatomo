package flatomo;

import flatomo.translator.RawTextureAtlas;

typedef Asset = {
	var atlases:Array<RawTextureAtlas>;
	var postures:Map<ItemPath, Posture>;
}
