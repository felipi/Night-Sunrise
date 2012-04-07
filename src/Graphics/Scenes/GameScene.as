package Graphics.Scenes
{
	import Graphics.Levels.GameLevel;
	
	import System.AssetManager;
	import System.GameManager;
	import System.Input.SceneInput;
	
	import caurina.transitions.Tweener;
	
	import fdd.events.QueueEvent;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class GameScene extends Sprite
	{
		public var input : SceneInput = new SceneInput();
		public var assetManager : AssetManager = new AssetManager();
		
		public static var FADE_OUT : String = "FadeOut";
				
		public function GameScene()
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, RemovedFromStage);
		}
		
		private function RemovedFromStage(e:Event):void {
			Destroy();	
		}
		
		public function Destroy() : void {
			while(numChildren > 0){
				trace("Removing");
				removeChildAt(0);
			}
		}
		
		public function LoadScene(): void {
			assetManager.Load();
			assetManager.queue.addEventListener(QueueEvent.COMPLETE, AssetLoadComplete);
			assetManager.queue.addEventListener(QueueEvent.UPDATE, AssetLoadUpdate);
		}
		
		public function AssetLoadUpdate(e:QueueEvent):void {
			
		}
		
		public function AssetLoadComplete(e:QueueEvent):void {
			
		}
		
		public function FadeOut(duration:Number ): void {
			Tweener.addTween(this, { alpha:0, time:duration,  onComplete:OnCompleteFadeOut } );
		}
		
		private function OnCompleteFadeOut():void
		{
			dispatchEvent(new Event(FADE_OUT) );
		}
		
	}
}