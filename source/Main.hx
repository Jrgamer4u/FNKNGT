package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var gameWidth:Int = 2560;
		var gameHeight:Int = 1440;
		var zoom:Float = -1;

		var ratioX:Float = stageWidth / gameWidth;
		var ratioY:Float = stageHeight / gameHeight;
		zoom = Math.min(ratioX, ratioY);
		gameWidth = Math.ceil(stageWidth / zoom);
		gameHeight = Math.ceil(stageHeight / zoom);

		addChild(new FlxGame(gameWidth, gameHeight, TitleState, zoom, 96, 96, true, true));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
