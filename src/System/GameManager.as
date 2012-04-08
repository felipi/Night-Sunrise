
package System
{
	import Data.Character;
	import Data.Global;
	
	import Graphics.Characters.BaseActor;
	import Graphics.FX.LightingEngine.LE;
	import Graphics.Levels.GameLevel;
	import Graphics.Scenes.GameScene;
	import Graphics.Scenes.LevelScene;
	import Graphics.Scenes.LoaderScene;
	import Graphics.Scenes.PreloaderScene;
	import Graphics.Scenes.TitleScene;
	
	import caurina.transitions.Tweener;
	
	import fdd.events.QueueEvent;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.net.URLRequest;

	public class GameManager
	{
		public static var DEBUG : Boolean = true;
		public static var EDITOR : Boolean = true;
		
		public static var assetManager : AssetManager = new AssetManager();
		
		public static var player : Player;
		public static var stage : Stage;
		public static var scene : GameScene;
		public static var level : GameLevel;
		public static var viewport : MovieClip;
		public static var resolutionWidth : Number = 720;
		public static var resolutionHeight : Number = 480;
		public static var levelName : String  = Global.startingScene;
		public static function get actor (): BaseActor { return player.actor;}
		public static function get character ():Character { return player.character; }
		
		public static function get currentWidth(): Number{
			if (stage != null){
				return stage.stageWidth;
			}else{
				return resolutionWidth;
			}
		}
		public static function get currentHeight(): Number{
			if (stage != null){
				return stage.stageHeight;
			}else{
				return resolutionHeight;
			}
		}
		
		public function GameManager()
		{
			DTrace("This shouldn't be instantiated");
		}
		
		//Global trace function that only works if debug flags are on
		public static function DTrace(...args) : void {
			if(DEBUG || EDITOR) trace(args);
		}
		
		//Initialize game
		public static function Initizalize(stg:Stage): void{
			stage = stg;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			
			var loader:PreloaderScene =  new PreloaderScene(new TitleScene(), assetManager);
			stage.addChild(loader);
		}
		
		//Load a new scene
		public static function NextScene(newScene:Class) : void{
			var next:GameScene = new newScene();
			stage.addChild(next);
			stage.swapChildren(next, scene);
			scene.FadeOut(0.75);
			scene.addEventListener(GameScene.FADE_OUT, 
			function(): void {
				stage.removeChild(scene);
				scene = next;
			});
		}
		
	}
}