package ;

@:enum
abstract ErrorCode(Int) to Int {
	var Successful = 0;
	var MissingArgumentOuput = 1;
	var MissingArgumentInput = 2;
	var InvaildArgumentInput = 3;
}
