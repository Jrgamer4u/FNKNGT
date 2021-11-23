package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;

		var tex = FlxAtlasFrames.fromSparrow('assets/images/campaign_menu_UI_characters.png', 'assets/images/campaign_menu_UI_characters.xml');
		frames = tex;

		animation.addByPrefix('bf', "BF idle dance white", 24);
		animation.addByPrefix('bfConfirm', 'BF HEY!!', 24, false);
		animation.addByPrefix('gf', "GF Dancing Beat WHITE", 24);
		animation.addByPrefix('fenberry', "fenberry idle dance BLACK LINE", 24);
		animation.addByPrefix('outlier', "OUTLIER idle dance", 24);

		animation.play(character);
		updateHitbox();
	}
}
