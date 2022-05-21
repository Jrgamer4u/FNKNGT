package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteStyle:String = "normal";

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var BLUE_NOTE:Int = 1;
	public static var GREEN_NOTE:Int = 2;
	public static var RED_NOTE:Int = 3;
	public static var arrowName:String = "";
	public static var arrowPixelNum:Int = 0;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, noteStyle:String = "normal")
	{
		super();
		this.noteStyle = noteStyle;
		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;
		switch (noteData)
		{
			case 0:
				arrowName = "purple";
			case 1:
				arrowName = "blue";
			case 2:
				arrowName = "green";
			case 3:
				arrowName = "red";
		}
		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			default:
				var daPath:String = "NOTE_assets";
				switch (noteStyle)
				{
					case "warning":
						daPath = "NOTE_warning";
					default:
						daPath = "NOTE_assets";
				}
				frames = Paths.getSparrowAtlas('NOTE_assets');

				animation.addByPrefix(arrowName + 'Scroll', arrowName + '0');

				animation.addByPrefix(arrowName + 'holdend', arrowName + ' hold end');

				animation.addByPrefix(arrowName + 'hold', ' hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		x += swagWidth * noteData;
		animation.play(arrowName + 'Scroll');

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			animation.play(arrowName + 'holdend');

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(arrowName + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
