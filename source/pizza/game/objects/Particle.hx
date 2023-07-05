import funkin.backend.assets.Paths;

class Particle extends flixel.FlxSprite {
	public function new(xPos:Float, yPos:Float, ignore, type:String, widthSpr:Int, heightSpr:Int, frames:Array<Int>) {
		super(xPos, yPos, null);

		loadGraphic(Paths.image('platformer/particles/'+type), true, widthSpr, heightSpr);
		animation.add(type, frames, 14, false);
		animation.play(type, true);
		scale.set(3,3);
	}

	public function update(elapsed:Float) {
		super.update(elapsed);
		if (animation.curAnim.finished) destroy();
	}
}