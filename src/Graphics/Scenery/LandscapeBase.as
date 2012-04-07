package Graphics.Scenery {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import System.GameManager;
	
	/**
	 * ...
	 * @author ...
	 */
	public class LandscapeBase extends MovieClip{
		
		public var horizontalScroll : Boolean;
		public var verticalScrolll : Boolean;
		public var landscapeImage : DisplayObject;
		
		public function LandscapeBase(image : DisplayObject, blur : Number = 0, hScroll : Boolean = false, vScroll : Boolean = false) {
			horizontalScroll = hScroll;
			verticalScrolll = vScroll;
			landscapeImage = image;
			addChild(landscapeImage);
			
			filters = [new BlurFilter(blur, blur)];
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function Update(e:Event):void {
			var scrollx : Number = (GameManager.level.cameraOffsetX) / (GameManager.level.levelWidth - GameManager.level.levelWidth/3.1);
			var scrolly : Number = (GameManager.level.cameraOffsetY) / (GameManager.level.levelHeight - GameManager.level.levelHeight/3.1);
			
			if (horizontalScroll) x = (width / 2) * (scrollx);
			if (verticalScrolll) y = (height/2) * (scrolly);
		}
		
	}

}