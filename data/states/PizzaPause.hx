import flixel.FlxCamera;
import funkin.backend.shaders.CustomShader;
var camShaders:Array<FlxCamera> = [];
var blurShader:CustomShader = new CustomShader("blur");
var monitor:FlxSprite;
var pauseCam:FlxCamera;
var pauseMusic;
function create() {
	FlxG.sound.music.volume = 0;

	for(c in FlxG.cameras.list) {
		camShaders.push(c);
		c.addShader(blurShader);
	}

	pauseCam = new FlxCamera();
	pauseCam.bgColor = 0xFFFFFFFF;
	FlxG.cameras.add(pauseCam, false);

	monitor = new FlxSprite().loadGraphic(Paths.image('platformer/pizzamonitor'), true, 320, 240);
	monitor.scale.set(3,3);
	monitor.updateHitbox();
	monitor.cameras = [pauseCam];
	monitor.animation.add('idle', [0,1], 4, true);
	monitor.animation.play('idle');
	monitor.screenCenter();
	add(monitor);

	pauseMusic = FlxG.sound.load(Paths.sound('Hiatus'), 100, true);
	pauseMusic.persist = false;
	pauseMusic.play(true);

	pauseCam.scroll.y+=monitor.height*2;
	FlxTween.tween(pauseCam.scroll, {y: 0}, 0.5, {ease: FlxEase.circOut});
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.SPACE) {
		FlxTween.tween(pauseCam.scroll, {y: monitor.height*2}, 0.5, {ease: FlxEase.circIn, onComplete: function() {
			for(e in camShaders)
				e.removeShader(blurShader);
			FlxG.cameras.remove(pauseCam);
			FlxG.sound.music.volume = 1;
			pauseMusic.stop();
			close();
		}});
	}
}