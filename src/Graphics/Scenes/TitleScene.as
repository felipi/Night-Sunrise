package Graphics.Scenes 
{
	import Data.Global;
	
	import Graphics.FX.BlobBackground;
	import Graphics.Scenes.GameScene;
	
	import System.AssetManager;
	import System.GameManager;
	import System.Input.SceneInput;
	
	import fdd.events.QueueEvent;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author Felipi
	 */
	public class TitleScene extends GameScene
	{
		private var loader:LoaderScene;
		
		public function TitleScene() 
		{
			loader = new LoaderScene(this);
			addChild(loader);
			
			var blob_bg:BlobBackground = new BlobBackground(GameManager.resolutionWidth,GameManager.resolutionHeight, 0x555555); //0x4f2fad
			//var blob_bg:BlobBackground = new BlobBackground(GameManager.currentWidth,GameManager.currentHeight, 0x555555); //0x4f2fad
			addChild(blob_bg);
			blob_bg.alpha = 0.5;
			blob_bg.blendMode = BlendMode.OVERLAY;
			
			var xmlloader : URLLoader = new URLLoader();
			xmlloader.load(new URLRequest(Global.deployedURL + "xml/scenes/title.xml"));	
			xmlloader.addEventListener(Event.COMPLETE, Initialize);
		}
		
		private function Initialize(e:Event):void {
			var xml : XML = new XML(e.target.data);
			
			var assets:XMLList = xml.scene.assets.asset;
			////trace(assets[1].@name);
			
			for (var i:uint = 0; i < assets.length(); i++) {
				assetManager.RegisterAsset(assets[i].@name, assets[i].@type, assets[i].@url);
			}

			LoadScene();
			input.addEventListener(SceneInput.SPACE, StartGame);
		}
		
		public override function AssetLoadComplete(e:QueueEvent): void {
			addChildAt(assetManager.Asset("TitleScreen") as DisplayObject, 0);
			
			loader.FadeOut(0.75);
			loader.addEventListener(GameScene.FADE_OUT, 
			function(): void {
				removeChild(loader);
			});
		}
		
		private function StartGame(e:Event):void 
		{
			//trace("Start Game");
			GameManager.NextScene(LevelScene);
			input.removeEventListener(SceneInput.SPACE, StartGame);
		}
		
	}

}