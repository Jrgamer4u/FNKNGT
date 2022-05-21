package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	var swagDialogue:FlxTypeText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				FlxG.sound.playMusic(Paths.music('breakfast'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 10) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 10);

		box = new FlxSprite(-20, 45);

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogueBox');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitLeft = new FlxSprite(1720, 240);

		if (PlayState.SONG.song.toLowerCase() == 'hell-o')
		{
			portraitLeft.frames = Paths.getSparrowAtlas('fenberryPortrait');
			portraitLeft.animation.addByPrefix('enter', 'fenberry Portrait Enter', 24, false);
		}
		else if (PlayState.SONG.song.toLowerCase() == 'outliiier')
		{
			portraitLeft.frames = Paths.getSparrowAtlas('outlierPortrait');
			portraitLeft.animation.addByPrefix('enter', 'outlier Portrait Enter', 24, false);
		}
		else if (PlayState.SONG.song.toLowerCase() == 'copycat')
		{
			portraitLeft.frames = Paths.getSparrowAtlas('playerstg1Portrait');
			portraitLeft.animation.addByPrefix('enter', 'playerstg1 Portrait Enter', 24, false);
		}
		else if (PlayState.SONG.song.toLowerCase() == 'player')
		{
			portraitLeft.frames = Paths.getSparrowAtlas('playerstg3Portrait');
			portraitLeft.animation.addByPrefix('enter', 'playerstg3 Portrait Enter', 24, false);
		}
		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		if (PlayState.SONG.song.toLowerCase() != 'roses')
		{
			add(portraitLeft);
			portraitLeft.visible = false;
			if (PlayState.SONG.song.toLowerCase() == 'thorns')
				portraitLeft.color = FlxColor.BLACK;
		}
		portraitRight = new FlxSprite(0, 240);
		portraitRight.frames = Paths.getSparrowAtlas('bfPortrait');
		portraitRight.animation.addByPrefix('enter', 'BF Portrait Enter', 24, false);
		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 1.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		swagDialogue = new FlxTypeText(24, 1000, Std.int(FlxG.width * 0.9), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.borderStyle = SHADOW;
		if (PlayState.SONG.song.toLowerCase() != "thorns")
		{
			swagDialogue.color = 0xFF212121;
			swagDialogue.borderColor = 0xFF949494;
		}
		else
		{
			swagDialogue.color = FlxColor.WHITE;
			swagDialogue.borderColor = FlxColor.BLACK;
		}
		swagDialogue.borderSize = 2;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
				dialogueOpened = true;
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'too':
				portraitRight.visible = false;
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			case 'bf':
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
