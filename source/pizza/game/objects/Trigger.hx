class Trigger extends flixel.FlxSprite {
	public var type:String;
	public var meta:Dynamic;
	public function new(ignore1, ignore2, ignore3, triggerType:String, params:Dynamic, inEditor:Bool) {
		immovable = true;
		moves = false;
		makeGraphic(16, 16, 0xFF00FF00);
		alpha = 0.001;
		if (inEditor) alpha = 0.5;

		type = triggerType;
		meta = params;
	}

	public function onTouch() {

	}
}