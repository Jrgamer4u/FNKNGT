package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Skip Start', 'Restart Song', 'Loop Song', 'AB Repeat', 'Exit to menu'];
	var curSelected:Int = 0;
	var pauseMusic:FlxSound;
	var loopCallback:Bool->Void;
	var loopState:LoopState;
	var skipselection:Bool = true;

	public function new(x:Float, y:Float, loopCallback:Bool->Void, loopState:LoopState)
	{
		super();
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		FlxG.sound.list.add(pauseMusic);
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		this.loopCallback = loopCallback;
		this.loopState = loopState;
		updateLoopState();

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Skip Start":
					if (FlxG.sound.music.time < 5000 && skipselection == true)
					{
						PlayState.swagCounter = 4;
						FlxG.sound.music.time += 7000;
						skipselection = false;
						close();
						Conductor.songPosition = FlxG.sound.music.time;
					}
					else
						menuItems = ['Resume', 'Restart Song', 'Exit to menu'];
					close();
				case "Loop Song":
					loopCallback(false);
					close();
				case "AB Repeat":
					loopCallback(true);
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
			}
		}
	}

	function updateLoopState()
	{
		FlxG.log.add(loopState);
		switch (loopState)
		{
			case NONE:
				menuItems[2] = 'Loop Song';
				menuItems[3] = 'AB Repeat';
			case REPEAT:
				menuItems[2] = 'Stop Repeating';
				menuItems[3] = 'AB Repeat';
			case ANODE:
				menuItems[2] = 'Cancel AB repeat';
				menuItems[3] = 'Confirm B Node';
			case ABREPEAT:
				menuItems[2] = 'Loop Song';
				menuItems[3] = 'Stop Repeating';
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
