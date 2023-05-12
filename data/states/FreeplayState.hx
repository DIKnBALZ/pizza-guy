import funkin.editors.ui.UIState;
function update(elapsed:Float) {
	if (FlxG.keys.justPressed.G) FlxG.switchState(new ModState('PlatformerState'));

	if (FlxG.keys.justPressed.B) FlxG.switchState(new UIState(true, 'editors/Paint'));
	
	if (FlxG.keys.justPressed.C) FlxG.switchState(new UIState(true, 'editors/PaintRework'));

	if (FlxG.keys.justPressed.FOUR) {
		FlxG.switchState(new UIState(true, 'DiscordState'));
	}
}