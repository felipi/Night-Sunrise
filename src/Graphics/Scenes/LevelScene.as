package Graphics.Scenes 
{
	import Data.Global;
	
	import Graphics.Levels.GameLevel;
	import Graphics.Scenes.GameScene;
	
	import System.AssetManager;
	import System.GameManager;
	
	import fdd.events.QueueEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Felipi
	 */
	public class LevelScene extends GameScene
	{
		public var level : GameLevel;
		public var loader : LoaderScene;
		
		public function LevelScene() 
		{
			loader = new LoaderScene(this);
			addChild(loader);
			var levelName: String = GameManager.levelName;
			
			var xmlloader : URLLoader = new URLLoader( );
			xmlloader.load(new URLRequest (Global.deployedURL + AssetManager.ASSETSXML + levelName + ".xml"));
			xmlloader.addEventListener(Event.COMPLETE, 
			function():void {
				
			var xml : XML = new XML(xmlloader.data);

			var assets:XMLList = xml.assets.asset;
			for (var i:uint = 0; i < assets.length(); i++) {
				assetManager.RegisterAsset(assets[i].@name, assets[i].@type, assets[i].@url);
			}
			
			//assetManager.RegisterAsset("level", AssetManager.LEVEL, levelName + ".swf");
			assetManager.RegisterAsset("xml", AssetManager.LEVELXML, levelName + ".xml");
			LoadScene();
			
			});
			/*
			var loader : Loader = new Loader();			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadComplete);
			loader.load(new URLRequest(levelName));
			*/
		}
		
		private function LoadComplete(e:Event):void 
		{
			//level = new GameLevel(assetManager.Asset("xml") as XML);
			//addChild(level);
		}
		
		public override function AssetLoadComplete(q:QueueEvent) : void {
			//trace(assetManager.Asset("xml"));
			level = new GameLevel( new XML ( assetManager.Asset("xml").data), assetManager ); // assetManager.Asset("level") as GameLevel;
			addChildAt(level,0);
			
			loader.FadeOut(0.75);
			loader.addEventListener(GameScene.FADE_OUT, 
			function(): void {
				removeChild(loader);
			});
			
		}
		
		public function Scroll(scrollx:Number, scrolly:Number):void {
			if (level == null) return;
			level.Scroll(scrollx, scrolly);
		}
		
	}

}