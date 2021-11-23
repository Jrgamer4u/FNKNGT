package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		loadGraphic('assets/images/iconGrid.png', true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('fenberry', [12, 13], 0, false, isPlayer);
		animation.add('outlier', [2, 4], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.play(char);
		scrollFactor.set();
	}
}
