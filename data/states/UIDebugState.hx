import funkin.editors.ui.UIState;

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.SEVEN) FlxG.switchState(new UIState(true, 'UIWindowTest'));
}