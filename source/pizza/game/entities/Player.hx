import flixel.FlxG;
import funkin.backend.assets.Paths;
import Math;
import Std;
import pizza.game.entities.NPC;
import openfl.utils.Assets;
import haxe.Json;
import funkin.backend.scripting.Script;

class Player extends funkin.backend.FunkinSprite {
	public var sprinting:Bool = false;
	public var speed:Float = 10000;
	public var jumpHeight:Float = 750;
	public var somethingIDK:Float = 750;
	public var maxVelX:Float = 800;
	public var blacklist:Array<String> = [];
	public var attackAnims:Array<String> = [];
	public var attackHitFrames:Array<Dynamic> = [];
	public var DONT:Bool = false;
	public var sliding:Bool = false;
	public var disableControls:Bool = false;
	public var dashed:Bool = false;
	public var playedWalkSound:Bool = false;
	public var playedLandSound:Bool = false;
	public var debugMode:Bool = false;
	public var activeHit:Bool = false;
	public var curCharacter:String = 'default';
	public var charJson;
	public var charScript;
	public function new(xPos:Float, yPos:Float, ?ignore, ?debug:Bool = false, ?skin:String = null) {
		moves = true;
		x = xPos;
		y = yPos;
		debugMode = debug;
		curCharacter = skin;

		charJson = Json.parse(Assets.getText(Paths.json('pizza/characters/'+curCharacter)));

		if (skin != null && Assets.exists(Paths.image('platformer/skins/player/'+curCharacter)))
			loadGraphic(Paths.image('platformer/skins/player/'+curCharacter), true, 100, 100);
		else
			loadGraphic(Paths.image('platformer/skins/player/main'), true, 100, 100);

		for(anim in charJson.animations) {
			if (anim.hitframes != null && anim.hitframes != []) {
				attackAnims.push(anim.name);
				attackHitFrames.push(anim.hitframes);
			}
			if (anim.blacklist) blacklist.push(anim.name);
			animation.add(anim.name, anim.indices, anim.fps, anim.loop);
		}

		if (!debugMode) {
			scale.set(1,1.91);
			updateHitbox();
			scale.set(2,2);
			animation.play('idle');
		} else {
			scale.set(2,2);
			updateHitbox();
		}
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

		if (!debugMode && !disableControls) {
			if (!(blacklist.contains(animation.name) && !animation.curAnim.finished) && !disableControls) {
				if (!sliding) {
					if (FlxG.keys.pressed.A) acceleration.x = -speed;
					else if (FlxG.keys.pressed.D) acceleration.x = speed;
					else acceleration.x = 0;
					if (FlxG.keys.pressed.SPACE) {
						if (isTouching(0x1000)) {
							DONT = true;
							animation.play('jump', true);
							velocity.y -= jumpHeight;
							DONT = false;
						} else {
							velocity.y -= elapsed * somethingIDK;
						}
					}
					sprinting = FlxG.keys.pressed.SHIFT;
		
					if (FlxG.keys.pressed.E || FlxG.mouse.pressed) {
						if (!sprinting || dashed) animation.play('attack', false);
						else if (Math.abs(velocity.x) >= maxVelX-1 && !dashed && sprinting) {
							dashed = true;
							animation.play('dash', false);
							velocity.y -= Math.abs(velocity.y);
							new FlxTimer().start(0.5, function(timer:FlxTimer) {
								animation.stop();
							});
						}
					}
		
					if (FlxG.keys.pressed.S || FlxG.mouse.pressedRight) {
						if (isTouching(0x1000) && !sliding && velocity.x != 0) {
							animation.play('roll', true);
							sliding = true;
						}
					}

					if (!sliding) maxVelocity.x = sprinting?maxVelX*1.25:maxVelX;

					acceleration.y = isTouching(0x1000)?0:2300;
				}
		
				if (animation.curAnim.name == 'roll' && animation.curAnim.finished) {
					animation.play('slide', true);
				}
		
				if (sliding) {
					sliding = ((FlxG.keys.pressed.S || FlxG.mouse.pressedRight) && velocity.x != 0);
				}
					
				if (!DONT && !sliding) {
					if ((velocity.y>0 && !isTouching(0x1000)) || (animation.name == 'jump' && animation.curAnim.finished)) animation.play('fall');
					else if (velocity.x!=0 && isTouching(0x1000) && animation.name != 'jump') animation.play('run');
					else if (velocity.x==0 && isTouching(0x1000) && animation.name != 'jump') animation.play('idle');
				}
		
				if (animation.curAnim.name == 'run') {
					animation.curAnim.frameRate = Std.int(Math.abs(velocity.x) / (40));
					if (animation.curAnim.curFrame == 1 && !playedWalkSound) {
						FlxG.sound.play(Paths.file('sounds/walk.wav'));
						playedWalkSound = true;
					} else if (animation.curAnim.curFrame != 1) {
						playedWalkSound = false;
					}
				}
			} else if (FlxG.keys.justPressed.CONTROL || FlxG.mouse.justPressedMiddle) {
				animation.play(velocity.y!=0?'fall':'idle', true);
				velocity.y -= Math.abs(velocity.y);
			}

			if (velocity.x != 0) flipX = velocity.x>0;
			if (isTouching(0x0100)) velocity.y = 10; // easiest fix of my life B)
			if (isTouching(0x0011)) velocity.x = 0; // easiest fix of my life B)
			if (isTouching(0x1000)) {
				dashed = false;
				if (!playedLandSound) {
					FlxG.sound.play(Paths.file('sounds/land.wav'));
					playedLandSound = true;
				}
			}

			if (velocity.y<0) playedLandSound = false;

			activeHit = attackAnims.contains(animation.name) && attackHitFrames[attackAnims.indexOf(animation.name)].contains(animation.curAnim.curFrame);
		}

		if (charScript != null) charScript.call('postUpdate', [elapsed]);

		super.update(elapsed);
	}
}