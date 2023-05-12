import flixel.FlxG;
import funkin.backend.assets.Paths;
import Math;
import Std;
import pizza.game.entities.NPC;
import openfl.utils.Assets;

class Player extends funkin.backend.FunkinSprite {
	public var sprinting:Bool = false;
	public var speed:Float = 10000;
	public var jumpHeight:Float = 750;
	public var somethingIDK:Float = 750;
	public var maxVelX:Float = 800;
	public var blacklist:Array<String> = ['attack', 'dash'];
	public var attackAnims:Array<String> = ['attack', 'dash', 'slide'];
	public var attackHitFrames:Array<Dynamic> = [[2,3], [0,1], [0,1]];
	public var DONT:Bool = false;
	// public var multiP:Bool = false;
	// public var multiID:Int = 0;
	public var sliding:Bool = false;
	public static var disableControls:Bool = false;
	public var dashed:Bool = false;
	public var playedWalkSound:Bool = false;
	public var playedLandSound:Bool = false;
	public var debugMode:Bool = false;
	public var activeHit:Bool = false;
	public function new(xPos:Float, yPos:Float, ?ignore, ?debug:Bool = false, ?skin:String = null) {
		moves = true;
		x = xPos;
		y = yPos;
		debugMode = debug;
		// multiP = multi;
		// multiID = id;

		if (skin != null && Assets.exists(Paths.image('platformer/stages/'+skin+'/player')))
			loadGraphic(Paths.image('platformer/stages/'+skin+'/player'), true, 100, 100);
		else
			loadGraphic(Paths.image('platformer/player/main'), true, 100, 100);

		animation.add('idle', [0,1,2,3,4,5,6], 14, true);
		animation.add('jump', [7,8,9], 14, false);
		animation.add('fall', [10,11], 14, true);
		animation.add('run', [12,13,14,15], 14, true);
		animation.add('attack', [18,19,20,21], 14, false);
		animation.add('roll', [23,24,25,26,27,28,29], 28, false);
		animation.add('slide', [30,29], 14, true);
		animation.add('dash', [24,25], 14, true);
		if (!debugMode) {
			scale.set(1,1.91);
			updateHitbox();
			scale.set(2,2);
			animation.play('idle');
		} else {
			scale.set(2,2);
			updateHitbox();
		}
		// offset.y = -55;
		drag.x = 5000;
		drag.y = 700;
		maxVelocity.x = maxVelX;
		maxVelocity.y = 1000;
	}

	public function update(elapsed:Float) {
		if (!debugMode) {
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
						if (Math.abs(velocity.x) >= maxVelX-1 && !dashed) {
							if (!sprinting) animation.play('attack', false);
							else {
								dashed = true;
								animation.play('dash', false);
								velocity.y -= Math.abs(velocity.y);
								new FlxTimer().start(0.5, function(timer:FlxTimer) {
									animation.stop();
								});
							}
						}
					}
		
					if (FlxG.keys.pressed.S || FlxG.mouse.pressedRight) {
						if (isTouching(0x1000) && !sliding && velocity.x != 0) {
							animation.play('roll', true);
							sliding = true;
							// velocity.x += flipX?500:-500;
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

		super.update(elapsed);
	}
}