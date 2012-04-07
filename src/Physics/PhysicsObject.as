package Physics {
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.display.MovieClip;
	import flash.events.Event;
	import Graphics.Levels.GameLevel;
	import System.GameManager;
	
	/**
	 * ...
	 * @author ...
	 */
	public class PhysicsObject extends MovieClip{
		
		private var _body : b2Body;
		
		public function PhysicsObject() {
			
		}
		
		public function get body():b2Body { return _body; }
		
		public function set body(value:b2Body):void {
			_body = value;
			if (value == null) {
				GameManager.level.world.DestroyBody(_body);
				removeEventListener(Event.ENTER_FRAME, Update);
				return;
			}
			_body.SetUserData(this);
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		protected virtual function Update(e:Event):void {
			var bodyPosition:b2Vec2 = body.GetPosition();
			var bodyRotation:Number = body.GetAngle();
			rotation = bodyRotation  * (180/Math.PI) % 360;
			x = GameLevel.BoxToFlash(bodyPosition.x);
			y = GameLevel.BoxToFlash(bodyPosition.y);			
		}
		
		public virtual function Contact():void {

		}
		
	}

}