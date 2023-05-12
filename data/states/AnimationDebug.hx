import funkin.editors.ui.UIState;
import funkin.editors.ui.UITopMenu;
import funkin.editors.ui.UIWarningSubstate;
import pizza.game.entities.Player;

var charcam:FlxCamera;
var uicam:FlxCamera;
var character:Player;
var startOffset:Array<Float> = [];
var startOffset2:Array<Float> = [];
var dragging:Bool = false;

function create() {
	FlxG.mouse.enabled = true;
	FlxG.mouse.visible = true;

	charcam = new FlxCamera(0, 0);
	charcam.bgColor = 0xFF444444;
	FlxG.cameras.remove(FlxG.camera, false);
	FlxG.cameras.add(charcam, false);
	FlxG.cameras.add(FlxG.camera, false);
	FlxG.camera.bgColor = 0x00000000;

	uicam = new FlxCamera(0, 0);
	uicam.bgColor = 0x00000000;
	FlxG.cameras.add(uicam, false);

	var topmenu:UITopMenu = new UITopMenu([
		{
			label: "File",
			childs: [
				{
					label: "Open",
					onSelect: () ->
					{
						var fDial = new FileDialog();
						fDial.onSelect.add(function(file){openChar(file);});
						fDial.browse(FileDialogType.OPEN, 'xml', null, 'Open a Codename Engine Character XML.');
					}
				},
				{
					label: "Save",
					onSelect: () ->
					{
						save();
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
									FlxG.switchState(new PlayState());
								}
							}
						]));
					}
				}
			]
		}
	]);
	topmenu.cameras = [uicam];
	add(topmenu);

	character = new Player(0, 0, null, true);
	character.cameras = [charcam];
	character.screenCenter();
	add(character);

	// charcam.zoom = 6;
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.EIGHT) FlxG.switchState(new UIState(true, 'AnimationDebug'));
	if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(new MainMenuState());

	if (FlxG.mouse.justPressed && mouseOverlapsChar()) {
		dragging = true;
		startOffset = [FlxG.mouse.getWorldPosition(charcam).x, FlxG.mouse.getWorldPosition(charcam).y];
		startOffset2 = [character.x, character.y];
	}

	if (FlxG.mouse.justReleased) {
		dragging = false;
		startOffset = null;
		startOffset2 = null;
	}

	if (dragging & FlxG.mouse.justMoved) {
		character.x = startOffset2[0] + (FlxG.mouse.getWorldPosition(charcam).x - startOffset[0]);
		character.y = startOffset2[1] + (FlxG.mouse.getWorldPosition(charcam).y - startOffset[1]);
	}

	if (FlxG.keys.pressed.A)
		charcam.scroll.x -= 500 / charcam.zoom * elapsed;
	if (FlxG.keys.pressed.S)
		charcam.scroll.y += 500 / charcam.zoom * elapsed;
	if (FlxG.keys.pressed.W)
		charcam.scroll.y -= 500 / charcam.zoom * elapsed;
	if (FlxG.keys.pressed.D)
		charcam.scroll.x += 500 / charcam.zoom * elapsed;
	if (FlxG.mouse.wheel < 0)
		charcam.zoom -= 2 * elapsed;
	if (FlxG.mouse.wheel > 0)
		charcam.zoom += 2 * elapsed;
}

function mouseOverlapsChar() { // i stole this code from YCE im sorry yosh
	var mousePos = FlxG.mouse.getWorldPosition(charcam);
	return (character.x - (character.offset.x) < mousePos.x
		&& character.x - (character.offset.x) + (character.frameWidth * character.scale.y) > mousePos.x
		&& character.y - (character.offset.y) < mousePos.y
		&& character.y - (character.offset.y) + (character.frameHeight * character.scale.y) > mousePos.y);
}