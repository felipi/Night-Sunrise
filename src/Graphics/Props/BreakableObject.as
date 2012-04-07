package Graphics.Props {
	import Box2D.Dynamics.b2Body;
	
	import Graphics.FX.ShatterBitmap;
	import Graphics.Props.IPropBase;
	
	import Physics.PhysicsObject;
	
	import System.GameManager;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author ...
	 */
	public class BreakableObject extends PhysicsObject implements IPropBase{

		public var stiffness : Number = 10;
		
		public function BreakableObject(xml : XML) {
			stiffness = xml.@stiffness;
			super();
		}
		
		public function Initialize(xml:XML) : void{
			
		}
		
		override public function Contact():void {
			super.Contact();
			
			if (body == null) return;
			if ( Math.abs(body.GetLinearVelocity().y) > stiffness) {
				(getChildAt(0) as ShatterBitmap).Break();
				body.SetUserData("dead");
				body = null;
				
				for each(var p : MovieClip in (getChildAt(0) as ShatterBitmap).piecesArray) {
					GameManager.level.AddObjectToCreationQueue(p);
				}
			}
			
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			if (numChildren > 0 ) return null;
			var bmd : BitmapData = new BitmapData(child.width, child.height, true, 0x000000);
			bmd.draw(child);
			
			var graphic : ShatterBitmap = new ShatterBitmap(bmd);
			return super.addChild(graphic);
		}
	}

	
}