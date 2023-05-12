import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import sys.io.File;
import haxe.ds.StringMap;
import flixel.addons.display.FlxGridOverlay;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UITopMenu;
import funkin.editors.ui.UIWarningSubstate;
import Math;
import pizza.game.objects.Tile;
import pizza.game.objects.Door;
import pizza.game.objects.Trigger;

var highlight;
var tilecam:FlxCamera;
var uicam:FlxCamera;
var topmenu:UITopMenu;
var tiles:StringMap<Array>;
var doors:StringMap<Array>;
var curShit:Int;
var camModifier:Float = 1;
var coords:FlxText;
var coordsInput:UITextBox;
var placingTrigger:Bool = false;
var switched:Bool = true;

function create() {
	FlxG.mouse.enabled = true;
	FlxG.mouse.visible = true;

	tilecam = new FlxCamera(0, 0);
	FlxG.cameras.add(tilecam, false);

	uicam = new FlxCamera(0, 0);
	uicam.bgColor = 0x00000000;
	FlxG.cameras.add(uicam, false);

	topmenu = new UITopMenu([
		{
			label: "File",
			childs: [
				{
					label: "Open",
					onSelect: () ->
					{
						open();
					}
				},
				{
					label: "Save Level",
					onSelect: () ->
					{
						save();
					}
				},
				{
					label: "Save Doors",
					onSelect: () ->
					{
						saveDoors();
					}
				},
				null,
				{
					label: "Exit",
					onSelect: () ->
					{
						openSubState(new UIWarningSubstate("Warning!", "You may or may not have unsaved changes. Are you sure you exit back to PlayState?", [
							{
								label: "No",
								onClick: function(t)
								{
								}
							},
							{
								label: "Yes",
								onClick: function(t)
								{
									FlxG.mouse.enabled = false;
									FlxG.mouse.visible = false;
									FlxG.switchState(new ModState('PlatformerState'));
								}
							}
						]));
					}
				}
			]
		},
		{
			label: "Edit",
			childs: [
				{
					label: "Make Door",
					onSelect: () ->
					{
						COCK(coordsInput.label.text);
					}
				},
				{
					label: "Playtest Level",
					onSelect: () ->
					{
						var txtString:String = '';
						for (key in tiles.keys()) {
							txtString += key +','+ tiles.get(key)[1]+'\n';
						}
						txtString = txtString.substring(0, txtString.length-1);
						levelData = txtString;

						var txtString2:String = '';
						for (key in doors.keys()) {
							txtString2 += key +','+ doors.get(key)[1]+'\n';
						}
						txtString2 = txtString2.substring(0, txtString2.length-1);
						doorData = txtString2;

						FlxG.mouse.enabled = false;
						FlxG.mouse.visible = false;
						FlxG.switchState(new ModState('PlatformerState'));
					}
				}
			]
		},
		{
			label: "View",
			childs: [
				{
					label: "Show Console"
				}
			]
		},
		{
			label: "Help",
			childs: [
				{
					label: "Controls"
				}
			]
		}
	]);
	topmenu.cameras = [uicam];
	add(topmenu);

	coords = new FlxText(0, 25, 0, 'X: 0\nY: 0', 25);
	coords.cameras = [uicam];
	coords.color = 0xFF000000;
	coords.x = FlxG.width-coords.width;
	add(coords);

	// coordsInput = new UITextBox(coords.x, coords.y+75, 250, 32, false);
	coordsInput = new UITextBox(coords.x, coords.y+75, '0,0', 320, 32, false);
	coordsInput.cameras = [uicam];
	coordsInput.x = FlxG.width-coordsInput.width;
	add(coordsInput);

	var bg:FlxSprite = FlxGridOverlay.create(64, 64);
	bg.cameras = [tilecam];
	bg.scrollFactor.set();
	add(bg);

	highlight = new Tile(0, 'default', true);
	highlight.cameras = [tilecam];
	highlight.scale.set(4, 4);
	highlight.updateHitbox();
	add(highlight);

	tiles = new StringMap();
	doors = new StringMap();
}

function update(elapsed:Float) {
	highlight.setPosition(Math.floor(FlxG.mouse.getWorldPosition(tilecam).x / 64) * 64, Math.floor(FlxG.mouse.getWorldPosition(tilecam).y / 64) * 64);
	if (!coordsInput.hovered) highlight.alpha = (!topmenu.anyMenuOpened && curContextMenu == null)?FlxG.mouse.screenY > 50?1:0.001:0.001;
	else highlight.alpha = 0.001;
	if (FlxG.keys.justPressed.EIGHT&&!coordsInput.hovered) FlxG.switchState(new UIState(true, 'PlatformerEditor'));
	if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new ModState('PlatformerState'));

	if (FlxG.keys.justPressed.A)
		tilecam.scroll.x -= 64*camModifier;
	if (FlxG.keys.justPressed.D)
		tilecam.scroll.x += 64*camModifier;
	if (FlxG.keys.justPressed.W)
		tilecam.scroll.y -= 64*camModifier;
	if (FlxG.keys.justPressed.S)
		tilecam.scroll.y += 64*camModifier;
	if (FlxG.keys.justPressed.G) {
		placingTrigger = !placingTrigger;
		switched = false;
	}

	camModifier = FlxG.keys.pressed.SHIFT?4:1;

	if (!placingTrigger) {
		if (!switched) {
			remove(highlight);
			highlight = new Tile(0, 'default', true);
			highlight.cameras = [tilecam];
			highlight.scale.set(4, 4);
			highlight.updateHitbox();
			add(highlight);
			switched = true;
		}

		if (FlxG.keys.justPressed.LEFT) curShit--;
		if (FlxG.keys.justPressed.RIGHT) curShit++;
		highlight.animation.frameIndex = curShit;

		if (FlxG.mouse.pressed && highlight.alpha == 1) {
			if (tiles.get(highlight.x+','+highlight.y) != null) {
				remove(tiles.get(highlight.x+','+highlight.y)[0]);
				tiles.remove(highlight.x+','+highlight.y);
			}
			var tile:Tile = new Tile(highlight.x, highlight.y, null, curShit==null?0:curShit, null);
			tile.scale.set(4, 4);
			tile.updateHitbox();
			tile.cameras = [tilecam];
			tiles.set(highlight.x+','+highlight.y, [tile, curShit==null?0:curShit]);
			add(tile);
		} else if (FlxG.mouse.pressedRight) {
			if (tiles.get(highlight.x+','+highlight.y) != null || tiles.get(highlight.x+','+highlight.y) != []) {
				trace(tiles.get(highlight.x+','+highlight.y)[0]);
				remove(tiles.get(highlight.x+','+highlight.y)[0]);
				tiles.remove(highlight.x+','+highlight.y);
			}
		}
	} else {
		if (!switched) {
			remove(highlight);
			highlight = new Trigger(0, 0, null, 'test', {testInfo: 'hello'}, true);
			highlight.cameras = [tilecam];
			highlight.scale.set(4, 4);
			highlight.updateHitbox();
			add(highlight);
			switched = true;
		}
	}

	coords.text = 'X: '+highlight.x+'\nY: '+highlight.y;
	coords.x = FlxG.width-coords.width;

	coordsInput.x = FlxG.width-(coordsInput.width*40);
}

function save() {
	var txtString:String = '';
	for (key in tiles.keys()) {
		txtString += key +','+ tiles.get(key)[1]+'\n';
	}
	txtString = txtString.substring(0, txtString.length-1);
	trace(txtString);

	var fDial = new FileDialog();
	fDial.onSelect.add(function(file) {
		File.saveContent(file, txtString);
	});
	fDial.browse(FileDialogType.SAVE, 'txt', null, 'save it');
}

function saveDoors() {
	var txtString:String = '';
	for (key in doors.keys()) {
		txtString += key +','+ doors.get(key)[1]+'\n';
	}
	txtString = txtString.substring(0, txtString.length-1);
	trace(txtString);

	var fDial = new FileDialog();
	fDial.onSelect.add(function(file) {
		File.saveContent(file, txtString);
	});
	fDial.browse(FileDialogType.SAVE, 'txt', null, 'save it');
}

function open() {
	var fDial = new FileDialog();
	fDial.onSelect.add(function(file) {
		for (key in tiles.keys()) {
			remove(tiles.get(key)[0]);
			tiles.remove(key);
		}

		var ass = File.getContent(file);
		ass = ass.split('\n');
		for (i in ass) {
			var cock = i.split(',');
			var tile:Tile = new Tile(cock[0], cock[1], null, cock[2], null);
			tile.scale.set(4, 4);
			tile.updateHitbox();
			tile.cameras = [tilecam];
			tiles.set(cock[0]+','+cock[1], [tile, cock[2]]);
			add(tile);
		}
	});
	fDial.browse(FileDialogType.BROWSE, 'txt', null, 'LEVEL');

	var fDial2 = new FileDialog();
	fDial2.onSelect.add(function(file2) {
		for (key in doors.keys()) {
			remove(doors.get(key)[0]);
			doors.remove(key);
		}

		var ass = File.getContent(file2);
		ass = ass.split('\n');
		for (i in ass) {
			var cock = i.split(',');
			var door:Door = new Door(0);
			door.setPosition(cock[0], cock[1]);
			door.cameras = [tilecam];
			add(door);
			doors.set(cock[0]+','+cock[1], [door, 'test']);
		}
	});
	fDial2.browse(FileDialogType.BROWSE, 'txt', null, 'DOORS');
	remove(highlight);
	add(highlight);
}

function COCK(pos:String) {
	var ass = pos.split(',');
	var door:Door = new Door('test');
	door.setPosition(ass[0], ass[1]);
	door.cameras = [tilecam];
	add(door);
	doors.set(ass[0]+','+ass[1], [door, 'test']);
}