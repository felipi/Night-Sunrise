package Graphics.Scenes {
	import Graphics.FX.BlobBackground;
	import Graphics.Scenes.GameScene;
	
	import System.AssetManager;
	import System.GameManager;
	
	import fdd.events.QueueEvent;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.system.System;
	
	/**
	 * ...
	 * @author ...
	 */
	public class PreloaderScene extends GameScene{
		
		private var _scene : GameScene;
		public function get scene(): GameScene { return _scene; }
		
		public var loaderBar : Sprite = new Sprite;
		private var icon : DisplayObject;
		
		public function PreloaderScene(sceneToLoad:GameScene, assetManager : AssetManager = null) {
			_scene = sceneToLoad;
			
			[Embed(source='/../bin/xml/globalAssets.xml', mimeType='application/octet-stream')]
			var GlobalAssets : Class;
			[Embed(source='../../../bin/Resources/Graphics/Pictures/title_2.png')]
			var LoadSprite : Class;
			[Embed(source='../../../bin/Resources/Graphics/Pictures/logo_small.png')]
			var LogoSprite : Class;
			
			var assetsXml : XML = XML(new GlobalAssets());
			
			var assetList : XMLList = assetsXml.assets.asset;
			for (var i : uint = 0; i < assetList.length(); i++) {
				assetManager.RegisterAsset(assetList[i].@name, assetList[i].@type, assetList[i].@url);
			}
			
			var loading : DisplayObject = new LoadSprite();
			addChild(loading);
			
			//var blob_bg:BlobBackground = new BlobBackground(GameManager.resolutionWidth,GameManager.resolutionHeight, 0xAAAAAA); //0x4f2fad
			//addChild(blob_bg);
			//blob_bg.alpha = 0.5;
			//blob_bg.blendMode = BlendMode.OVERLAY;
			
			icon = new LogoSprite();
			icon.x = GameManager.resolutionWidth - icon.width*2;
			icon.y = GameManager.resolutionHeight - icon.height*2;
			addChild(icon);
			
			loaderBar.x = (icon.x+icon.width/2)-50;
			loaderBar.y = icon.y + icon.height + 5;
			addChild(loaderBar);
			
			if(assetManager == null){
				_scene.assetManager.queue.addEventListener(QueueEvent.UPDATE, OnUpdate);
			} else {
				assetManager.queue.addEventListener(QueueEvent.UPDATE, OnUpdate);
			}
		}
		

		
		private function OnUpdate(e:QueueEvent):void 
		{
			loaderBar.graphics.clear();
			loaderBar.graphics.beginFill(0x000000);
			loaderBar.graphics.drawRect(0, 0, 100, 10);
			loaderBar.graphics.endFill();
			
			loaderBar.graphics.beginFill(0x4f2fad);
			loaderBar.graphics.drawRect(1, 1, e.percentLoaded * 98, 8);
			loaderBar.graphics.endFill();
		}
		
		/*public override function AssetLoadComplete(q:QueueEvent):void {
			addChild( assetManager.Asset("loading") as DisplayObject );
		}*/
		
		/*public function Update(percentage : Number):void {
			//trace(percentage * 100);
		}*/
		
	}

}