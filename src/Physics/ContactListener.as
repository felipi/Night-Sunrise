package Physics {
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Graphics.Characters.Actor;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ContactListener extends b2ContactListener{
		
		public function ContactListener() {
			
		}
		
	
		override public function Add(point:b2ContactPoint):void {
			super.Add(point);
			if (point.shape1.GetUserData() is GroundSensor && !point.shape2.IsSensor()) {
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.Idle();
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.canJump = true;
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.isColliding = true;
			}
			
			//if (point.shape1.GetBody().GetUserData() == null || point.shape2.GetBody().GetUserData() == null) return; 
			var func : String = "Contact";
			if (func in point.shape1.GetBody().GetUserData()) {
				point.shape1.GetBody().GetUserData().Contact();
			}
			if (func in point.shape2.GetBody().GetUserData()) {
				point.shape2.GetBody().GetUserData().Contact();
			}
		}
		
		 override public function Persist(point:b2ContactPoint):void {
			super.Persist(point);
			if (point.shape1.GetUserData() is GroundSensor && !point.shape2.IsSensor()) {
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.canJump = true;
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.isColliding = true;
			}
		}
		
		override public function Remove(point:b2ContactPoint):void {
			super.Remove(point);
		
			if (point.shape1.GetUserData() is GroundSensor) {
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.canJump = false;
				(point.shape1.GetUserData() as GroundSensor).parentPhysicsActor.graphic.isColliding = false;
			}
		}
		
	}

}