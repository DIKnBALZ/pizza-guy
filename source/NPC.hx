import funkin.backend.assets.Paths;
import flixel.FlxG;
import flixel.util.FlxTimer;

class NPC extends funkin.backend.FunkinSprite {
	public var doShit:Bool = false;
	public var curPlayer = null;
	public var lookAt:Bool = true;
	public var curCharacter:String = 'sign';
	public function new(xPos:Float, yPos:Float, ?ignore, ?debug:Bool = false, ?skin:String = null) {
		moves = true;
		x = xPos;
		y = yPos;
		debugMode = debug;
		curCharacter = skin;

		charJson = Json.parse(Assets.getText(Paths.json('pizza/characters/'+curCharacter)));

		if (skin != null && Assets.exists(Paths.image('platformer/skins/npc/'+curCharacter)))
			loadGraphic(Paths.image('platformer/skins/npc/'+curCharacter), true, 100, 100);
		else
			loadGraphic(Paths.image('platformer/skins/npc/main'), true, 100, 100);

		// animation.add('idle', [0,1,2], 14, true);
		// animation.add('talk', [3,4,5,6,7,8,9,10,11,12], 14, true);
		// animation.play('idle');

		for(anim in charJson.animations) animation.add(anim.name, anim.indices, anim.fps, anim.loop);

		if (!debugMode) {
			scale.set(4,2);
			updateHitbox();
			scale.set(2,2);
			animation.play('idle');
		} else {
			scale.set(2,2);
			updateHitbox();
		}
		offset.y = 14;
	}

	public function update(elapsed:Float) {
		super.update(elapsed);

		if (doShit) animation.play('talk');
		else animation.play('idle');

		if (curPlayer!=null&&lookAt) flipX = curPlayer.x<(x+(width/2));
	}
}