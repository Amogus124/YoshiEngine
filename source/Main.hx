package;

import flixel.FlxG;
import lime.utils.Log;
import haxe.CallStack;
import openfl.events.ErrorEvent;
import haxe.Exception;
import openfl.errors.Error;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// YOSHI ENGINE STUFF
	public static var engineVer:Array<Int> = [1,4,0];
	public static var buildVer:String = "";

	public static var supportedFileTypes = ["lua", "hx", "hscript"];

	// You can pretty much ignore everything from here on - your code should go in your states.
	// HAHA no.

	public static function main():Void
	{
		#if cpp
		cpp.Lib.print("main");
		Lib.current.addChild(new Main());
		#else
		trace("main");
		Lib.current.addChild(new Main());
		#end
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent) {
			var m:String = e.error;
			if (Std.is(e.error, Error)) {
				var err = cast(e.error, Error);
				m = '${err.message}';
			} else if (Std.is(e.error, ErrorEvent)) {
				var err = cast(e.error, ErrorEvent);
				m = '${err.text}';
			}
			m += '\r\n ${CallStack.toString(CallStack.exceptionStack())}';
 			Application.current.window.alert('An error occured !\r\nYoshi Engine ver. ${engineVer.join(".")} $buildVer\r\n\r\n${m}\r\n\r\nThe engine is still in it\'s early stages, so if you want to report that bug, go ahead and create an Issue on the GitHub page !', e.error);
			e.stopPropagation();
			e.stopImmediatePropagation();
		});
		
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
		stage.window.onDropFile.add(function(path:String) {
			if (Std.is(FlxG.state, MusicBeatState)) {
				var checkSubstate:FlxState->Void = function(state) {
					if (Std.is(state, MusicBeatState)) {
						var state = cast(state, MusicBeatState);
						if (Std.is(state.subState, MusicBeatSubstate)) {
		
						} else {
							state.onDropFile(path);
						}
					} else if (Std.is(state, MusicBeatSubstate)) {
						var state = cast(state, MusicBeatSubstate);
						if (Std.is(state.subState, MusicBeatSubstate)) {
		
						} else {
							state.onDropFile(path);
						}
					}
				};
				var state = cast(FlxG.state, MusicBeatState);
				checkSubstate(state);
			}
		});
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

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
			initialState = TitleState;
		#end
		initialState = LoadingScreen;
		#if clipRectTest
		initialState = ClipRectTest;
		#end
		#if mod_test
		initialState = ModTest;
		#end
		#if animate_test
		initialState = AnimateTest;
		#end
		#if lua_test
		initialState = LuaTest;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
