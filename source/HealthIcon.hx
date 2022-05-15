package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('fenberry', [12, 13], 0, false, isPlayer);
		animation.add('outlier', [2, 4], 0, false, isPlayer);
		animation.add('playerstg1', [5, 6], 0, false, isPlayer);
		animation.add('playerstg2', [7, 8], 0, false, isPlayer);
		animation.add('playerstg3', [9, 10], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
