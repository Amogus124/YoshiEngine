package;

import EngineSettings.Settings;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverState extends FlxTransitionableState
{
	var bfX:Float = 0;
	var bfY:Float = 0;

	public var char = "Friday Night Funkin':bf";
	public var firstDeathSFX = "Friday Night Funkin':fnf_loss_sfx";
	public var gameOverMusic = "Friday Night Funkin':gameOver";
	public var gameOverMusicBPM = 100;
	public var retrySFX = "Friday Night Funkin':gameOverEnd";

	public function new(x:Float, y:Float)
	{
		super();

		bfX = x;
		bfY = y;
	}

	override function create()
	{
		/* var loser:FlxSprite = new FlxSprite(100, 100);
			var loseTex = FlxAtlasFrames.fromSparrow(AssetPaths.lose.png, AssetPaths.lose.xml);
			loser.frames = loseTex;
			loser.animation.addByPrefix('lose', 'lose', 24, false);
			loser.animation.play('lose');
			// add(loser); */

		var bf:Boyfriend = new Boyfriend(bfX, bfY);
		// bf.x -= bf.charGlobalOffset.x;
		// bf.y -= bf.charGlobalOffset.y;
		// bf.scrollFactor.set();
		add(bf);
		bf.playAnim('firstDeath');

		FlxG.camera.follow(bf, LOCKON, 0.001 * 60 / Settings.engineSettings.data.fpsCap);
		/* 
			var restart:FlxSprite = new FlxSprite(500, 50).loadGraphic(AssetPaths.restart.png);
			restart.setGraphicSize(Std.int(restart.width * 0.6));
			restart.updateHitbox();
			restart.alpha = 0;
			restart.antialiasing = true;
			// add(restart); */

		FlxG.sound.music.fadeOut(2, FlxG.sound.music.volume * 0.6);

		// FlxTween.tween(restart, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
		// FlxTween.tween(restart, {y: restart.y + 40}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});

		super.create();
	}

	private var fading:Bool = false;

	override function update(elapsed:Float)
	{
		var pressed:Bool = FlxG.keys.justPressed.ANY;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.ANY)
				pressed = true;
		}

		pressed = false;

		if (pressed && !fading)
		{
			fading = true;
			FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween)
			{
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		super.update(elapsed);
	}
}
