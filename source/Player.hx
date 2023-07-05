import flixel.FlxG;
import funkin.backend.assets.Paths;
import Math;
import Std;
import NPC;
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
	public var attacked:Bool = false;
	public var playedWalkSound:Bool = false;
	public var playedLandSound:Bool = false;
	public var debugMode:Bool = false;
	public var activeHit:Bool = false;
	public var curCharacter:String = 'default';
	public var charJson;
	public var charScript;

	public var left = FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT;
	public var down = FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN;
	public var up = FlxG.keys.pressed.W || FlxG.keys.pressed.UP;
	public var right = FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT;

	public var leftJ = FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT;
	public var downJ = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN;
	public var upJ = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
	public var rightJ = FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT;

	public var jump = FlxG.keys.pressed.SPACE || FlxG.keys.pressed.C;
	public var jumpJ = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.C;

	public var sprint = FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.Z;
	public var sprintJ = FlxG.keys.justPressed.SHIFT || FlxG.keys.justPressed.Z;

	public var action = FlxG.keys.pressed.E || FlxG.keys.pressed.X;
	public var actionJ = FlxG.keys.justPressed.E || FlxG.keys.justPressed.X;

	public var cancel = FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.V;
	public var cancelJ = FlxG.keys.justPressed.CONTROL || FlxG.keys.justPressed.V;
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
		left = FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT;
		down = FlxG.keys.pressed.S || FlxG.keys.pressed.DOWN;
		up = FlxG.keys.pressed.W || FlxG.keys.pressed.UP;
		right = FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT;

		leftJ = FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT;
		downJ = FlxG.keys.justPressed.S || FlxG.keys.justPressed.DOWN;
		upJ = FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
		rightJ = FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT;

		jump = FlxG.keys.pressed.SPACE || FlxG.keys.pressed.C;
		jumpJ = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.C;

		sprint = FlxG.keys.pressed.SHIFT || FlxG.keys.pressed.Z;
		sprintJ = FlxG.keys.justPressed.SHIFT || FlxG.keys.justPressed.Z;

		action = FlxG.keys.pressed.E || FlxG.keys.pressed.X;
		actionJ = FlxG.keys.justPressed.E || FlxG.keys.justPressed.X;

		cancel = FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.V;
		cancelJ = FlxG.keys.justPressed.CONTROL || FlxG.keys.justPressed.V;

		if (charScript != null) charScript.call('update', [elapsed]);

		if (!debugMode && !disableControls) {
			if (!(blacklist.contains(animation.name) && !animation.curAnim.finished) && !disableControls) {
				if (!sliding) {
					if (left) acceleration.x = -speed;
					else if (right) acceleration.x = speed;
					else acceleration.x = 0;
					if (jump) {
						if (isTouching(0x1000)) {
							DONT = true;
							animation.play('jump', true);
							velocity.y -= jumpHeight;
							DONT = false;
						} else {
							velocity.y -= elapsed * somethingIDK;
						}
					}
					sprinting = sprint;
		
					if (action) {
						if ((!sprinting || dashed) && !attacked) {
							animation.play('attack', false);
							attacked = true;
						} else if (Math.abs(velocity.x) >= maxVelX-1 && !dashed && sprinting) {
							dashed = true;
							animation.play('dash', false);
							velocity.y -= Math.abs(velocity.y);
							new FlxTimer().start(0.5, function(timer:FlxTimer) {
								animation.stop();
							});
						}
					}
		
					if (down) {
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
					sliding = (down && velocity.x != 0);
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
			} else if (cancel) {
				animation.play(velocity.y!=0?'fall':'idle', true);
				velocity.y -= Math.abs(velocity.y);
			}

			if (velocity.x != 0) flipX = velocity.x>0;
			if (isTouching(0x0100)) velocity.y = 10; // easiest fix of my life B)
			if (isTouching(0x0011)) velocity.x = 0; // easiest fix of my life B)
			if (isTouching(0x1000)) {
				attacked = false;
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