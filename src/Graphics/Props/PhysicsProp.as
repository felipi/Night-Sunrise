package Graphics.Props 
{
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	
	import Graphics.Levels.GameLevel;
	import Graphics.Props.IPropBase;
	
	import Physics.PhysicsObject;
	
	import System.GameManager;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author Felipi
	 */
	public class PhysicsProp extends PhysicsObject implements IPropBase
	{
		
		private var contactSound : Sound;
		private var lightmap : Sprite;
		
		public function PhysicsProp() 
		{
			
		}
		
		public virtual function Initialize(xml : XML) : void {
			var bdef : b2BodyDef = new b2BodyDef();
			bdef.position = new b2Vec2(GameLevel.FlashToBox(this.x) + GameLevel.FlashToBox(this.width / 2),
										GameLevel.FlashToBox(this.y) + GameLevel.FlashToBox(this.height/2));
			var sdef : b2PolygonDef = new b2PolygonDef();
			sdef.density = xml.@density;
			sdef.friction = xml.@friction;
			sdef.restitution = xml.@restitution;
			if(xml.@passable == "true") sdef.isSensor = true;
			sdef.SetAsBox(GameLevel.FlashToBox(this.width/2), GameLevel.FlashToBox(this.height/2));
			
			var body : b2Body = GameManager.level.world.CreateBody(bdef);
			body.CreateShape(sdef);
			body.SetMassFromShapes();
			
			if(xml.@massScale != undefined){
				var mass : b2MassData = new b2MassData();
				mass.mass = body.GetMass() * xml.@massScale;
				mass.I = body.GetInertia();
				mass.center = body.GetLocalCenter();
				
				body.SetMass( mass );
			}
			
			this.body = body;
			
			contactSound = GameManager.level.assetManager.Asset(xml.@contactSound) as Sound;
		}
		
		override public function Contact():void {
			super.Contact();
		
			if (contactSound != null) {
				var soundTransform : SoundTransform = new SoundTransform();
				soundTransform.volume = Math.abs(body.GetLinearVelocity().x * body.GetLinearVelocity().y) / 10;
				contactSound.play(0, 0, soundTransform);
			}
		}
		
	}

}