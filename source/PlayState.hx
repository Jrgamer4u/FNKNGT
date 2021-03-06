package;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import vlc.VideoHandler;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:Song.SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var swagCounter:Int = 0;

	var reuploadWatermark:FlxText;

	private var vocals:FlxSound;

	private var theotherone:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var allNotes:Array<Note> = [];
	private var unspawnNotes:Array<Note> = [];
	private var loopA:Float = 0;
	private var loopB:Float;
	private var loopState:LoopState = NONE;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var player2Strums:FlxTypedGroup<FlxSprite>;

	private var strumming2:Array<Bool> = [false, false, false, false];

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 2;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var shakeCam:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = [':bf:hello', ':too:cool'];
	var diaEnd:Array<String> = [':bf:bye', ':too:yall'];

	var fbfBGweek:FlxSprite;

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var filters:Array<BitmapFilter> = [];

	var optionsubstate:OptionsSubState;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var canDie:Bool = true;

	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var trackedAssets:Array<FlxBasic> = [];

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('hell-o');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		var file:String = Paths.txt(SONG.song.toLowerCase() + '/' + 'Dialogue');
		var file2:String = Paths.txt(SONG.song.toLowerCase() + '/' + 'DiaEnd');

		try
		{
			dialogue = CoolUtil.coolTextFile(file);
			diaEnd = CoolUtil.coolTextFile(file2);
		}
		catch (ex:Any)
		{
			dialogue = null;
			diaEnd = null;
		}

		switch (SONG.song.toLowerCase())
		{
			case 'hell-o' | 'whas' | 'berryfen':
				{
					curStage = 'fbfBGweek1';

					var fbfBGweek:FlxSprite = new FlxSprite(-800, -400).loadGraphic(Paths.image('fbfBGweek1'));

					fbfBGweek.antialiasing = true;
					fbfBGweek.active = false;
					add(fbfBGweek);
					fbfBGweek.scale.set(2, 2);
				}
			case 'outliiier' | 'poiiint' | 'staaack theee stateees':
				{
					curStage = 'fbfBGweek2';

					var fbfBGweek:FlxSprite = new FlxSprite(-800, -400).loadGraphic(Paths.image('fbfBGweek2'));

					fbfBGweek.antialiasing = true;
					fbfBGweek.active = false;
					add(fbfBGweek);
					fbfBGweek.scale.set(2, 2);
				}
			default:
				{
					curStage = 'fbfBGweek3';

					var fbfBGweek:FlxSprite = new FlxSprite(-800, -400).loadGraphic(Paths.image('fbfBGweek3'));

					fbfBGweek.antialiasing = true;
					fbfBGweek.active = false;
					add(fbfBGweek);
					fbfBGweek.scale.set(2, 2);
				}
		}

		var gfVersion:String = 'gf';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		theotherone = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(theotherone.getGraphicMidpoint().x, theotherone.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				theotherone.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'fenberry':
				camPos.x += 350;
				theotherone.x -= 300;
				theotherone.y -= 100;
				theotherone.scale.set(0.8, 0.8);
			case 'outlier':
				theotherone.y += 280;
				camPos.y += 280;
				theotherone.scale.set(0.5, 0.5);
			case 'playerstg1':
				theotherone.y += 300;
			case 'playerstg2':
				theotherone.y += 150;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		add(gf);

		add(theotherone);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		player2Strums = new FlxTypedGroup<FlxSprite>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 4);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		add(healthBar);

		reuploadWatermark = new FlxText((FlxG.width / 2), (FlxG.height / 2), 0,
			"download FNKNGT at https://github.com/Jrgamer4u/FNKNGT \ndownload FNKNGT at https://gamebanana.com/mods/336029 \ndownload vanilla Funkin at https://github.com/ninjamuffin99/Funkin \nplay vanilla Funkin at https://www.newgrounds.com/portal/view/770371 \n",
			12);
		reuploadWatermark.setPosition((FlxG.width / 2) - (reuploadWatermark.width / 2), (FlxG.height / 2) + 50);
		reuploadWatermark.scrollFactor.set();
		reuploadWatermark.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(reuploadWatermark);
		reuploadWatermark.visible = true;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		reuploadWatermark.cameras = [camHUD];

		startingSong = true;

		FlxG.sound.cache(Paths.inst(PlayState.SONG.song));
		if (SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.song));

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case 'outliiier':
					schoolIntro(doof);
				case 'hell-o':
					playCutscene('Algodoo.mp4');
				case 'copycat':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'outliiier':
					schoolIntro(doof);
				case 'hell-o':
					schoolIntro(doof);
				case 'copycat':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function endDia(?dialogueBox:DialogueBox):Void
	{
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				inCutscene = true;
				add(dialogueBox);
			}
			else
				endSong();
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		ShaderFilters();
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			theotherone.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('introGo'), 0.004);
				case 1:
					FlxG.sound.play(Paths.sound('introGo'), 0.063);
				case 2:
					FlxG.sound.play(Paths.sound('introGo'), 0.316);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("go"));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 1);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function playCutscene(name:String)
	{
		inCutscene = true;

		var video:VideoHandler = new VideoHandler();
		FlxG.sound.music.stop();
		video.playVideo(Paths.video(name));
		video.finishCallback = function()
		{
			startCountdown();
		}
	}

	function playEndCutsceneLastSong(name:String)
	{
		inCutscene = true;

		var video:VideoHandler = new VideoHandler();
		FlxG.sound.music.stop();
		video.playVideo(Paths.video(name));
		video.finishCallback = function()
		{
			FlxG.switchState(new StoryMenuState());
		}
	}

	function playEndCutscene(name:String)
	{
		inCutscene = true;

		var video:VideoHandler = new VideoHandler();
		FlxG.sound.music.stop();
		video.playVideo(Paths.video(name));
		video.finishCallback = function()
		{
			SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase());
			FlxG.switchState(new PlayState());
		}
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		loopB = FlxG.sound.music.length - 100;
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<Section.SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0;
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daNoteStyle);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,
						daNoteStyle);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2;
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		allNotes = deepCopyNotes(unspawnNotes);
		generatedMusic = true;
	}

	function deepCopyNotes(noteArray:Array<Note>, ?startingpoint:Float = 0):Array<Note>
	{
		var noteRef:Note = null;
		var newNoteArray:Array<Note> = [];

		for (note in noteArray)
		{
			if (note.strumTime > startingpoint)
			{
				noteRef = newNoteArray.length > 0 ? newNoteArray[newNoteArray.length - 1] : null;
				var deepCopy:Note = new Note(note.strumTime, note.noteData, noteRef, note.isSustainNote);
				deepCopy.mustPress = note.mustPress;
				deepCopy.x = note.x;
				newNoteArray.push(deepCopy);
			}
		}
		return newNoteArray;
	}

	function loopHandler(abLoop:Bool):LoopState
	{
		FlxG.log.add("Made it" + abLoop);
		if (abLoop)
		{
			switch (loopState)
			{
				case REPEAT | NONE:
					if (!startingSong)
						loopA = Conductor.songPosition;
					else
						loopA = 0;
					loopState = ANODE;
					FlxG.log.add("Setting A Node");
				case ANODE:
					loopB = Conductor.songPosition;
					loopState = ABREPEAT;
					FlxG.log.add("Setting B Node");
				case ABREPEAT:
					loopState = NONE;
					FlxG.log.add("Removing Nodes");
			}
		}
		else
		{
			switch (loopState)
			{
				case NONE | ABREPEAT:
					loopA = 0;
					loopB = FlxG.sound.music.length - 100;
					loopState = REPEAT;
					FlxG.log.add("Looping Entire Song");
				case REPEAT | ANODE:
					loopState = NONE;
					FlxG.log.add("No longer Looping");
			}
		}
		return loopState;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var arrowIndicator:String = "";

			switch (Math.abs(i))
			{
				case 0:
					arrowIndicator = "left";
				case 1:
					arrowIndicator = "down";
				case 2:
					arrowIndicator = "up";
				case 3:
					arrowIndicator = "right";
			}

			babyArrow.x += Note.swagWidth * i;
			switch (curStage)
			{
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix(Note.arrowName, 'arrow' + arrowIndicator.toUpperCase());

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					babyArrow.animation.addByPrefix('static', 'arrow' + arrowIndicator.toUpperCase());
					babyArrow.animation.addByPrefix('pressed', arrowIndicator.toLowerCase() + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', arrowIndicator.toLowerCase() + ' confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				player2Strums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	override public function onFocus():Void
		super.onFocus();

	override public function onFocusLost():Void
		super.onFocusLost();

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		if (shakeCam)
			FlxG.camera.shake(0.01, 0.05);
		#if !debug
		perfectMode = false;
		#end

		var timeScale = FlxG.timeScale;
		if (FlxG.keys.justPressed.G)
			timeScale /= 2;
		if (FlxG.keys.justPressed.H)
			timeScale *= 2;
		if (FlxG.keys.justPressed.T)
			timeScale = 1;
		timeScale = timeScale < 0.1 ? 0.1 : timeScale > 16 ? 16 : timeScale;
		FlxG.timeScale = timeScale;

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, loopHandler.bind(_), loopState));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			canDie = false;
			FlxG.switchState(new ChartingState());
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (healthBar.percent < 10)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 90)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * FlxG.timeScale;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * FlxG.timeScale;
			FlxG.watch.addQuick("songPosition", Conductor.songPosition);
			if (loopState != NONE && Conductor.songPosition >= loopB)
			{
				Conductor.songPosition = loopA;
				FlxG.sound.music.time = loopA;
				resyncVocals();
				unspawnNotes = deepCopyNotes(allNotes, loopA);
				songScore = 0;
				combo = 0;
			}

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}
		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (camFollow.x != theotherone.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				camFollow.setPosition(theotherone.getMidpoint().x + 150, theotherone.getMidpoint().y - 100);

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (controls.RESET)
		{
			if (!inCutscene)
			{
				health = 0;
				FlxG.log.add("RESET = True");
			}
		}

		if (controls.CHEAT)
		{
			health += 1;
			FlxG.log.add("User is cheating!");
		}

		if (health <= 0 && canDie)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			unloadAssets();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							theotherone.playAnim('singLEFT' + altAnim, true);
						case 1:
							theotherone.playAnim('singDOWN' + altAnim, true);
						case 2:
							theotherone.playAnim('singUP' + altAnim, true);
						case 3:
							theotherone.playAnim('singRIGHT' + altAnim, true);
					}

					player2Strums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm');
							sustain2(spr.ID, spr, daNote);
						}
					});

					theotherone.holdTimer = 0;

					if (SONG.needsVoices)
					{
						vocals.volume = 1;
						vocals.fadeOut(Conductor.stepCrochet / 1000, 1, function(_)
						{
							vocals.volume = 0;
						});
					}

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});

			player2Strums.forEach(function(spr:FlxSprite)
			{
				if (strumming2[spr.ID])
					spr.animation.play("confirm");

				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function commitsomething():Void
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		FlxG.switchState(new StoryMenuState());
	}

	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
	{
		var length:Float = note.sustainLength;

		if (length > 0)
			strumming2[strum] = true;

		var bps:Float = Conductor.bpm / 60;
		var spb:Float = 1 / bps;

		if (!note.isSustainNote)
		{
			new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
			{
				if (!strumming2[strum])
					spr.animation.play("static", true);
				else if (length > 0)
				{
					strumming2[strum] = false;
					spr.animation.play("static", true);
				}
			});
		}
	}

	function endSong():Void
	{
		canDie = false;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				var doof2:DialogueBox = new DialogueBox(false, diaEnd);
				doof2.scrollFactor.set();
				doof2.finishThing = commitsomething;
				doof2.cameras = [camHUD];

				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				unloadAssets();

				switch (SONG.song.toLowerCase())
				{
					case 'staaack theee stateees':
						playEndCutsceneLastSong('test.mp4');
					case 'player':
						endDia(doof2);
					default:
						FlxG.switchState(new StoryMenuState());
				}

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				FlxG.log.add('LOADING NEXT SONG');
				FlxG.log.add(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				unloadAssets();

				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			FlxG.log.add('WENT BACK TO FREEPLAY??');
			unloadAssets();
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.375)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.1)
		{
			daRating = 'good';
			score = 200;
		}

		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						noteCheck(controlArray[daNote.noteData], daNote);
					else
					{
						for (coolNote in possibleNotes)
							noteCheck(controlArray[coolNote.noteData], coolNote);
					}
				}
				else
					noteCheck(controlArray[daNote.noteData], daNote);
			}
			else
				badNoteCheck();
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			// if (note.noteStyle == 'danger')
			// 	health = 0;

			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');
			combo = 0;

			songScore -= (songScore - 10) >= 0 ? 10 : songScore;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			boyfriend.stunned = true;

			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
			badNoteCheck();
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			if (note.noteStyle == 'danger')
				health = 0;

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
					spr.animation.play('confirm', true);
			});

			note.wasGoodHit = true;
			vocals.volume = 1;
			vocals.fadeOut(Conductor.stepCrochet / 1000, 1, function(_)
			{
				vocals.volume = 0;
			});

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var startedMoving:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		/*
			if (SONG.song.toLowerCase() == 'song')
			{
				if (curStep == 'step')
					shakeCam = true;
				if (curStep == 'step2')
					shakeCam = false;
			}
		 */
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				theotherone.dance();
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.playAnim('idle');

		if (curBeat % 16 == 15)
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15)
			reuploadWatermark.visible = true;
		else if (curBeat % 8 == 7)
			reuploadWatermark.visible = false;
	}

	function ShaderFilters():Void
	{
		if (OptionsSubState.Deuteranopiabool)
		{
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			filters.push(new ColorMatrixFilter(matrix));
		}

		if (OptionsSubState.Protanopiabool)
		{
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			filters.push(new ColorMatrixFilter(matrix));
		}

		if (OptionsSubState.Tritanopiabool)
		{
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			filters.push(new ColorMatrixFilter(matrix));
		}
		camHUD.setFilters(filters);
		camGame.setFilters(filters);
		camHUD.filtersEnabled = true;
		camGame.filtersEnabled = true;
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		trackedAssets.insert(trackedAssets.length, Object);
		return super.add(Object);
	}

	function unloadAssets():Void
	{
		for (asset in trackedAssets)
			remove(asset);
	}

	var curLight:Int = 0;
}
