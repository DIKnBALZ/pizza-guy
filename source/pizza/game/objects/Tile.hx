import funkin.backend.assets.Paths;

class Tile extends funkin.backend.FunkinSprite {
	public function new(xPos:Float, yPos:Float, ?ignore, ?type:Int, ?tileset:String) {
		immovable = true;
		moves = false;
		x = xPos;
		y = yPos;

		// loadGraphic(Paths.image('platformer/tileset'), true, 16, 16);

		if (tileset != null) loadGraphic(Paths.image('platformer/stages/'+tileset+'/tileset'), true, 16, 16);
		else loadGraphic(Paths.image('platformer/tileset'), true, 16, 16);

		animation.frameIndex = type;
	}
}