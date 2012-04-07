package Physics {
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import Graphics.Characters.Actor;
	import Graphics.Levels.GameLevel;
	/**
	 * ...
	 * @author ...
	 */

	 	public class PhysicsActor{
		public var body:b2Body;
		public var graphic:Actor;

		public function PhysicsActor(b:b2Body, g:Actor){
			body = b;
			graphic = g;
			
			var ground_sensor:b2PolygonDef = new b2PolygonDef();
			ground_sensor.isSensor = true;
			ground_sensor.userData = new GroundSensor(this);
			ground_sensor.SetAsOrientedBox(GameLevel.FlashToBox(graphic.width/3.5),GameLevel.FlashToBox(graphic.height/16),new b2Vec2(0,GameLevel.FlashToBox(graphic.height/16)+GameLevel.FlashToBox(graphic.height/2)), 0);
			body.CreateShape(ground_sensor);
			
			graphic.addEventListener(Event.ENTER_FRAME, Update);
		}	
		
		private function Update(e:Event):void {
			var bodyPosition:b2Vec2 = body.GetPosition();
			var bodyRotation:Number = body.GetAngle();
			graphic.x = GameLevel.BoxToFlash(bodyPosition.x);
			graphic.y = GameLevel.BoxToFlash(bodyPosition.y)+graphic.height/2;
			graphic.rotation = bodyRotation  * (180/Math.PI) % 360;
		}

	}

}