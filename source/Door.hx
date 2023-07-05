import funkin.backend.assets.Paths;

class Door extends flixel.FlxSprite {
	public function new(room:String, xPos:Float, yPos:Float) {
		x = xPos;
		y = yPos;
		loadGraphic(Paths.image('platformer/door'));
		scale.set(4, 4);
		updateHitbox();
		active = false;
	}
}