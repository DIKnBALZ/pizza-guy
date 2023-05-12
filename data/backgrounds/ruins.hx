import flixel.addons.display.FlxBackdrop;
function create() {
	FlxG.camera.bgColor = 0xFFFA6A64;
	
	var mountains:FlxBackdrop = new FlxBackdrop(Paths.image('platformer/stages/ruins/mountains'), FlxAxes.X);
	mountains.scrollFactor.set(0.005,0.0025);
	mountains.scale.set(5,5);
	mountains.updateHitbox();
	mountains.y += 250;
	mountains.active = false;
	add(mountains);
	
	var buildings:FlxBackdrop = new FlxBackdrop(Paths.image('platformer/stages/ruins/buildings'), FlxAxes.X);
	buildings.scrollFactor.set(0.03,0.005);
	buildings.scale.set(5,5);
	buildings.updateHitbox();
	buildings.y += 250;
	buildings.active = false;
	add(buildings);
}