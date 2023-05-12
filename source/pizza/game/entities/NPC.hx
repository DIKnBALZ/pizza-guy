import funkin.backend.assets.Paths;
import flixel.FlxG;
import flixel.util.FlxTimer;

class NPC extends funkin.backend.FunkinSprite {
	public var doShit:Bool = false;
	public var curPlayer = null;
	public var lookAt:Bool = true;
	public function new(xPos:Float, yPos:Float) {
		moves = true;
		x = xPos;
		y = yPos;
		loadGraphic(Paths.image('platformer/peppino'), true, 100, 100);
		animation.add('idle', [0,1,2], 14, true);
		animation.add('talk', [3,4,5,6,7,8,9,10,11,12], 14, true);
		animation.play('idle');
		scale.set(4,2);
		updateHitbox();
		scale.set(2,2);
		offset.y = 14;
	}

	public function update(elapsed:Float) {
		super.update(elapsed);

		if (doShit) animation.play('talk');
		else animation.play('idle');

		if (curPlayer!=null&&lookAt) flipX = curPlayer.x<(x+(width/2));
	}
}