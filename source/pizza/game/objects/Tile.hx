import funkin.backend.assets.Paths;

class Tile extends flixel.FlxSprite {
	public function new(type:Int, tileset:String) {
		immovable = true;
		moves = false;
		loadGraphic(Paths.image('platformer/stages/'+tileset+'/tileset'), true, 16, 16);
		animation.frameIndex = type;
	}
}