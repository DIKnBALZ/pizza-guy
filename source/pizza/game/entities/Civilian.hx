import funkin.backend.assets.Paths;
import flixel.FlxG;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import haxe.Json;
import funkin.backend.scripting.Script;

class Civilian extends funkin.backend.FunkinSprite {
	public var speed:Float = 250;
	public var maxVelX:Float = 800;
	public var walking:Bool = false;
	public var doShit:Bool = true;
	public var direction:String = 'right';
	public var walkTimer:Int = 0;
	public var curPlayer = null;
	public var dead:Bool = false;
	public var charJson;
	public var charScript;
	public var curCharacter:String = 'civilian';
	public var debugMode:Bool = false;
	public function new(xPos:Float, yPos:Float, ?ignore, ?debug:Bool = false, ?skin:String = null) {
		moves = true;
		x = xPos;
		y = yPos;
		debugMode = debug;

		charJson = Json.parse(Assets.getText(Paths.json('pizza/characters/'+curCharacter)));

		if (skin != null && Assets.exists(Paths.image('platformer/skins/civilian/'+skin)))
			loadGraphic(Paths.image('platformer/skins/civilian/'+skin), true, 100, 100);
		else
			loadGraphic(Paths.image('platformer/skins/civilian/main'), true, 100, 100);

		// animation.add('idle', [0], 14, true);
		// animation.add('run', [1,2,3,4,5], 14, true);
		// animation.add('death', [6], 14, true);

		for(anim in charJson.animations) animation.add(anim.name, anim.indices, anim.fps, anim.loop);

		if (!debugMode) {
			scale.set(1,2);
			updateHitbox();
			scale.set(2,2);
			animation.play('idle');
		} else {
			scale.set(2,2);
			updateHitbox();
		}

		offset.y = -60;
		drag.x = 5000;
		drag.y = 700;
		maxVelocity.x = maxVelX;
		maxVelocity.y = 1000;

		if (Assets.exists(Paths.script('data/pizza/characters/'+skin))) {
			charScript = Script.create(Paths.script('data/pizza/characters/'+skin));
			charScript.load();
			charScript.call('create', [xPos, yPos, debug, skin]);
		}
	}

	public function update(elapsed:Float) {
		if (charScript != null) charScript.call('update', [elapsed]);

		if (!debugMode) {
			acceleration.y = isTouching(0x1000)?0:2300;
			if (animation.curAnim.name != 'death') {
				if (FlxG.random.int(1,100) == 25 && doShit) {
					doShit = false;
					walking = true;
					direction = FlxG.random.bool(50)?'left':'right';
				}
				if (walking) {
					if (walkTimer < 100) {
						velocity.x = direction=='right'?speed:-speed;
						walkTimer++;
					} else {
						walking = false;
						doShit = true;
					}

					if (x < 0) direction = 'right';
				} else walkTimer = 0;
				if (velocity.x != 0) {
					flipX = velocity.x>0;
					animation.play('run');
				} else animation.play('idle');

				if (curPlayer!=null) {
					if (curPlayer.activeHit) {
						doShit = false;
						walking = false;
						velocity.y -= 1500;
						animation.play('death', true);
						FlxG.camera.zoom+=0.1;
						// FlxG.state.persistentUpdate = false;
						// FlxG.state.persistentDraw = true;
						FlxG.camera.shake(0.025, 0.1, function() {
							// FlxG.state.persistentUpdate = true;
							// FlxG.state.persistentDraw = true;
						});
						FlxG.sound.play(Paths.file('sounds/hitAlt.wav'));
						dead = true;
					}
				}
			}
		}

		if (charScript != null) charScript.call('postUpdate', [elapsed]);

		super.update(elapsed);
	}
}