compc ^
	-swf-version 23 ^
	-source-path starling\starling\src ^
	-include-sources starling\starling\src ^
	-output starling.swc
 
haxe ^
	-swf nothing.swf ^
	--no-output ^
	--gen-hx-classes ^
	-swf-lib starling.swc ^
	--macro patchTypes('starling.patch')

rename hxclasses tmp
mkdir hxclasses
move tmp\com hxclasses\com
move tmp\starling hxclasses\starling
rd /s /q tmp

pause
