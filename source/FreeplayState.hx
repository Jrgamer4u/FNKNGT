package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var tweenScore:Int = 0;
	var intendedScore:Int = 0;

	var songWait:FlxTimer = new FlxTimer();

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var trackedAssets:Array<Dynamic> = [];

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
			songs.push(new SongMetadata(initSonglist[i], 0, 'outlier'));

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		if (StoryMenuState.weekUnlocked[1] || isDebug)
			addWeek(['Hell-O', 'Whas', 'Berryfen'], 1, ['fenberry']);

		if (StoryMenuState.weekUnlocked[2] || isDebug)
			addWeek(['Copycat', 'Controller', 'Player'], 2, ['playerstg1', 'playerstg2', 'playerstg3']);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
		songs.push(new SongMetadata(songName, weekNum, songCharacter));

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		scoreText.text = "PERSONAL BEST:" + tweenScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			unloadAssets();
			FlxG.switchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 0;
		if (curDifficulty > 0)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		FlxTween.num(tweenScore, intendedScore, 0.25, {ease: FlxEase.expoOut}, function(v:Float)
		{
			tweenScore = Math.round(v);
		});

		switch (curDifficulty)
		{
			case 0:
				diffText.text = 'NORMAL';
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		FlxTween.num(tweenScore, intendedScore, 0.25, {ease: FlxEase.expoOut}, function(v:Float)
		{
			tweenScore = Math.round(v);
		});

		FlxG.sound.music.stop();
		songWait.cancel();
		songWait.start(1, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		});

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		trackedAssets.insert(trackedAssets.length, Object);
		return super.add(Object);
	}

	function unloadAssets():Void
	{
		for (asset in trackedAssets)
			remove(asset);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
