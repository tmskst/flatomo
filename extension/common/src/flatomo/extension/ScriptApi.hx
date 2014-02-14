package flatomo.extension;

enum ScriptApi {
	Enable;
	Disable;
	Refresh;
	Save(item:FlatomoItem);
}
