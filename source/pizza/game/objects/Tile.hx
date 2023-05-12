import funkin.backend.assets.Paths;

class Tile extends flixel.FlxSprite {
	public function new(type:Int, tileset:String, debug:Bool = false) {
		immovable = true;
		moves = false;
		if (!debug) loadGraphic(Paths.image('platformer/stages/'+tileset+'/tileset'), true, 16, 16);
		else loadGraphic(Paths.image('platformer/tileset'), true, 16, 16);
		animation.frameIndex = type;
	}
}