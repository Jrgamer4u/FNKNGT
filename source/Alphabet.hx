package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitChars:Array<String> = [];

	var isBold:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "")
			typed ? startTypedText() : addText();
	}

	public function addText()
	{
		doSplitChars();

		var xPos:Float = 0;
		for (character in splitChars)
		{
			if (character == " " || character == "-")
				lastWasSpace = true;

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1)
			{
				if (lastSprite != null)
					xPos = lastSprite.x + lastSprite.width;

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0);

				if (isBold)
					letter.createBold(character);
				else
					letter.createLetter(character);

				add(letter);

				lastSprite = letter;
			}
		}
	}

	function doSplitChars():Void
		splitChars = _finalText.split("");

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitChars();

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitChars[loopNum] == " ")
				lastWasSpace = true;

			var isNumber:Bool = AlphaCharacter.numbers.contains(splitChars[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitChars[loopNum]);

			if (AlphaCharacter.alphabet.indexOf(splitChars[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}
				else
					xPosResetted = false;

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti);
				letter.row = curRow;
				if (isBold)
					letter.createBold(splitChars[loopNum]);
				else
				{
					if (isNumber)
						letter.createNumber(splitChars[loopNum]);
					else if (isSymbol)
						letter.createSymbol(splitChars[loopNum]);
					else
						letter.createLetter(splitChars[loopNum]);

					letter.x += 90;
				}

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitChars.length);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
			x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.getSparrowAtlas('alphabet');
		frames = tex;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
			letterCase = 'capital';

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 60;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				y += 50;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				y -= 0;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
