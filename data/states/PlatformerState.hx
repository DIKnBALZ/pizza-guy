import pizza.game.entities.Player;
import pizza.game.entities.Civilian;
import pizza.game.entities.NPC;
import pizza.game.objects.Tile;
import pizza.game.objects.Door;
import pizza.game.objects.Particle;

import sys.io.File;

import openfl.utils.Assets;

import lime.app.Application;

import haxe.io.Path;
import haxe.ds.StringMap;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.addons.display.FlxBackdrop;


import funkin.backend.shaders.CustomShader;
import funkin.backend.scripting.ScriptPack;
import funkin.backend.scripting.Script;
import funkin.editors.ui.UIState;

// import funkin.scripting.ModSubState;
static var levelName:String = 'roomtest';
static var roomName:String = 'main';
static var levelData:String = '';
static var doorData:String = '';
static var backgroundName:String = 'ruins';
static var curNPC:NPC = null;
static var scripts:ScriptPack;
static var bgScript:Script;
static var bgJson;
var doors:StringMap<Array>;
var tiles:StringMap<Array>;
var tileGroup:FlxTypedGroup;
var player:Player;
var hudcam:FlxCamera;
var civilians:Array<Civilian> = [];
var npcs:Array<NPC> = [];
var tv:FlxSprite;
var camPos:FlxSprite;
function create() {
	FlxG.camera.zoom = 0.6;
	FlxG.mouse.enabled = true;
	FlxG.mouse.visible = false;

	scripts = new ScriptPack("PlatformerState"); // here
	scripts.setParent(this); // i woulda put this                but it doesnt work for me so rip ig
	bgScript = Script.create(Paths.script('data/backgrounds/'+backgroundName));
	scripts.add(bgScript);

	bgJson = Json.parse(Assets.getText(Paths.json('backgrounds/'+backgroundName)));

	for(file in Paths.getFolderContent('data/pizza/scripts')) {
		var fileShits = file.split('.');
		if (Script.scriptExtensions.contains(fileShits[1].toLowerCase()))
			scripts.add(Script.create(Paths.script('data/pizza/scripts/'+file)));
	}

	camPos = new FlxSprite(0,0);

	CoolUtil.playMusic(Paths.sound('Challenge'), true);

	hudcam = new FlxCamera(0, 0);
	hudcam.bgColor = 0x00000000;
	FlxG.cameras.add(hudcam, false);

	player = new Player(25, 25, null, false, bgJson.playerSkin);
	var civilian = new Civilian(50, 10, null, false, bgJson.civilianSkin);
	civilians.push(civilian);

	var testnpc:NPC = new NPC(1152, 448);
	npcs.push(testnpc);

	tiles = new StringMap();
	doors = new StringMap();

	// var w:Float = (FlxG.camera.width / 9);
	// var h:Float = (FlxG.camera.height / 4);
	// FlxG.camera.deadzone = FlxRect.get((FlxG.camera.width - w) / 2, (FlxG.camera.height - h) / 2 - h * 0.25, w, h);
	// FlxG.camera.minScrollX = 0;
	// FlxG.camera.maxScrollY = FlxG.height;

	var ass = levelData == '' ? File.getContent(StringTools.replace(Paths.txt('levels/'+levelName+'/'+roomName+'/room'), 'assets', 'mods/cne-stuff')) : levelData;
	ass = ass.split('\n');
	tileGroup = new FlxTypedGroup();
	for (i in ass) {
		var cock = i.split(',');
		var tile:Tile = new Tile(cock[2], backgroundName, false);
		tile.x = cock[0];
		tile.y = cock[1];
		tile.scale.set(4, 4);
		tile.updateHitbox();
		tiles.set(cock[0]+','+cock[1], [tile, cock[2]]);
		tileGroup.add(tile);
	}

	tv = new FlxSprite().loadGraphic(Paths.image('platformer/pizzaguytv'), true, 100, 100);
	tv.cameras = [hudcam];
	tv.scale.set(3,3);
	tv.updateHitbox();
	tv.x=FlxG.width-tv.width;
	tv.animation.add('idle', [0,1], 14, true);
	tv.animation.add('attack', [2,3], 14, true);
	tv.animation.add('noise', [4,5], 14, true);
	tv.animation.play('idle');
	add(tv);

	scripts.load();
	scripts.call('create');

	add(tileGroup);
	ass = doorData == '' ? File.getContent(StringTools.replace(Paths.txt('levels/'+levelName+'/'+roomName+'/doors'), 'assets', 'mods/cne-stuff')) : doorData;
	ass = ass.split('\n');
	for (i in ass) {
		var cock = i.split(',');
		var door:Door = new Door(0);
		door.setPosition(cock[0], cock[1]);
		add(door);
		doors.set(cock[0]+','+cock[1], [door, 'test']);
	}
	for (i in npcs) add(i);
	add(player);
	for (i in civilians) add(i);

	FlxG.camera.follow(camPos, 0.001);
	FlxG.camera.followLerp = 0.3;
	FlxG.camera.pixelPerfectRender = true;
}

function update(elapsed:Float) {
	scripts.call('update', [elapsed]);

	camPos.x = player.x+(player.width/2);
	camPos.y = player.y+(player.height/2);

	FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, curNPC==null?0.8:0.9, 0.06);

	switch(player.animation.name) {
		default:
			tv.animation.play('idle');
		case 'attack' || 'dash' || 'slide':
			tv.animation.play('attack');
		case 'death':
			tv.animation.play('noise');
	}

	FlxG.collide(player, tileGroup);
	for (i in civilians) if (i.animation.curAnim.name != 'death') FlxG.collide(i, tileGroup);

	// IMPORATNT!!! WHEN YOU CAN CALL CUSTOM FUNCTIONS DO DOORS
	// for (i in doors) {
	// 	if (player.overlaps(i)) {
	// 		if (FlxG.gamepads.lastActive.firstPressedID()==3 && canEnterDoor) {
	// 			var anus = new ModState('PlatformerState');
	// 			anus.levelName = 
	// 			FlxG.switchState()
	// 		}
	// 	}
	// }

	for (i in civilians) if (i.y > FlxG.height) {remove(i); i.destroy(); civilians.remove(i);}
	for (i in npcs) if (i.y > FlxG.height) {remove(i); i.destroy(); npcs.remove(i);}
	// if (player.y > FlxG.height) FlxG.switchState(new ModState('PlatformerState'));

	for (i in npcs) {
		curNPC = player.overlaps(i, false)?i:null;
		if (curNPC!=null) curNPC.curPlayer = player;
		i.doShit = curNPC==i;
	}

	for (i in civilians) {
		if (player.overlaps(i, false)) {
			i.curPlayer = player;
			if (player.activeHit && !i.dead) {
				add(new Particle(i.x-43.5, i.y+47.5, null, 'hit', 87, 95, [0,1,2,3,4,5,6,7]));
			}
		} else i.curPlayer = null;
	}

	if (FlxG.keys.justPressed.EIGHT)
		exitState(new ModState('PlatformerState'));

	if (FlxG.keys.justPressed.SEVEN)
		exitState(new UIState(true, 'PlatformerEditor'));

	if (FlxG.keys.justPressed.SIX)
		exitState(new UIState(true, 'AnimationDebug'));

	if (FlxG.keys.justPressed.ESCAPE)
		exitState(new MainMenuState());

	if (FlxG.keys.justPressed.ENTER) {
		persistentUpdate = false;
		persistentDraw = true;
		openSubState(new ModSubState('PizzaPause'));
	}

	FlxG.worldBounds.set(-1000000, -2000000, 2000000, 4000000);

	scripts.call('postUpdate', [elapsed]);
}

function exitState(nextState) {
	levelData = '';
	doorData = '';
	FlxG.switchState(nextState);
}