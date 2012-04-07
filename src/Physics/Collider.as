package Physics
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import System.GameManager;
	
	public class Collider extends PhysicsObject
	{
		public function Collider()
		{
			
		}
		
		public function Paint(texture : DisplayObject, w : Number, h : Number) : void {
			var bmd : BitmapData = new BitmapData(texture.width, texture.height, true, 0x000000);
			bmd.draw(texture);
			
			graphics.beginBitmapFill(bmd, null, true, true);
			graphics.drawRect(-w/2, -h/2, w, h);
			graphics.endFill();
			
			GameManager.level.middleLayer.addChild(this);
		}
		
	}
}