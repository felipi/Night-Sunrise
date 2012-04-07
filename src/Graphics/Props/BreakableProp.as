package Graphics.Props
{
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonDef;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	
	import Graphics.FX.ShatterBitmap;
	import Graphics.Levels.GameLevel;
	
	import Physics.PhysicsObject;
	
	import System.GameManager;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	
	public class BreakableProp extends PhysicsProp implements IPropBase
	{
		private var contactSound : Sound;
		
		public function BreakableProp() {
			
		}
		
		override public function Initialize(xml : XML):void{
			//super.Initialize(xml);
			(getChildAt(0) as ShatterBitmap).Break();
			var lastBody:b2Body;
			
			
			var bodies:Array = new Array();
			for(var bli:int = 0; bli < (getChildAt(0) as ShatterBitmap).totalX; bli++){
				bodies[bli] = new Array();
				for(var blj:int = 0; blj < (getChildAt(0) as ShatterBitmap).totalY; blj++){
					bodies[bli][blj] = null;
				}	
			}
			
			var sbitmap : ShatterBitmap = (getChildAt(0) as ShatterBitmap);
			var bdef : b2BodyDef = new b2BodyDef();
			body = GameManager.level.world.CreateBody(bdef);
			//var sdef : b2PolygonDef = new b2PolygonDef();
			//bdef.position = new b2Vec2(GameLevel.FlashToBox(sbitmap.x - GameManager.level.cameraOffsetX), GameLevel.FlashToBox(sbitmap.y - GameManager.level.cameraOffsetY));
			
			var massSet : Boolean = false;
			
			for each(var object : MovieClip in sbitmap.piecesArray) {
				if((object as MovieClip).empty)
					continue;
				
//				var physicsObject : PhysicsObject = new PhysicsObject();
//				physicsObject.addChild(object);
//				physicsObject.x = object.x;
//				physicsObject.y = object.y;
//				object.x = object.y = 0;
//				//object.scaleX = object.scaleY = xml.@scale;
//				//object.x -= object.width / 2;
//				//object.y -= object.height / 2;
//				GameManager.level.middleLayer.addChild(physicsObject);
//				var subbdef : b2BodyDef = new b2BodyDef();
//				var pos : Point = object.localToGlobal(new Point(0, 0));
//				subbdef.position = new b2Vec2(GameLevel.FlashToBox(pos.x - GameManager.level.cameraOffsetX), GameLevel.FlashToBox(pos.y - GameManager.level.cameraOffsetY));
//				physicsObject.body = GameManager.level.world.CreateBody(subbdef);
//				
//				bodies[px][py] = physicsObject.body;
				
			//var bdef : b2BodyDef = new b2BodyDef();
			
			var sdef:b2PolygonDef = new b2PolygonDef();
			//subbdef.angle = object.rotation * (Math.PI / 180) % 360;
			
			var vertices : Array = (object as MovieClip).vertices
			var px:int = (object as MovieClip).matrixi;
			var py:int = (object as MovieClip).matrixj;
			var pw:Number = (object as MovieClip).piecew;
			var ph:Number = (object as MovieClip).pieceh;
			
			sdef.vertexCount = vertices.length;
			for (var i:int=0; i < vertices.length; i++ ){
				sdef.vertices[i].Set(GameLevel.FlashToBox( vertices[i].x - px*pw), GameLevel.FlashToBox( vertices[i].y - py*ph));
			}
			sdef.density = xml.@density;
			sdef.friction = xml.@friction;
			sdef.restitution = xml.@restitution;
			
			//body = GameManager.level.world.CreateBody(bdef);
			body.CreateShape(sdef);
			//physicsObject.body.SetMassFromShapes();
			
			//physicsObject.body.SetUserData(object);
			
			}
			
			body.SetMassFromShapes();
			
//			var damp : Number = 0;
//			var frequency : Number = 1.0;
//			var collide : Boolean = true;
//			
//			var jointDef : b2DistanceJointDef = new b2DistanceJointDef();
//			var joint:b2Joint;
//			jointDef.dampingRatio = damp;
//			jointDef.frequencyHz = frequency;
//			jointDef.collideConnected = collide;
//			
//			for(bli = 0; bli < sbitmap.totalX; bli++){
//			for(blj = 0; blj < sbitmap.totalY; blj++){
//			
//				if(bodies[bli][blj] == null) continue;
//				if(blj > 0){
//		
//					if(bodies[bli][blj-1] == null) continue;
//						var b1:b2Body=bodies[bli][blj];
//						var b2:b2Body=bodies[bli][blj-1];
//						
//						var p1b1:b2Vec2 = b1.GetWorldCenter().Copy(); p1b1.Add(new b2Vec2(- GameLevel.FlashToBox(sbitmap.pieceW/2),0 ) );
//						var p1b2:b2Vec2 = b2.GetWorldCenter().Copy(); p1b2.Add(new b2Vec2(- GameLevel.FlashToBox(sbitmap.pieceW/2),0 ) );
//						var p2b1:b2Vec2 = b1.GetWorldCenter().Copy(); p2b1.Add(new b2Vec2(GameLevel.FlashToBox(sbitmap.pieceW/2),0 ) );
//						var p2b2:b2Vec2 = b2.GetWorldCenter().Copy(); p2b2.Add(new b2Vec2(GameLevel.FlashToBox(sbitmap.pieceW/2),0 ) );
//						jointDef.Initialize(b1, b2, p1b1, p1b2);  
//						joint = GameManager.level.world.CreateJoint(jointDef);
//						jointDef.Initialize(b1, b2, p2b1, p2b2);
//						joint = GameManager.level.world.CreateJoint(jointDef);
//						jointDef.Initialize(b1, b2, b1.GetWorldCenter(), b2.GetWorldCenter());
//						joint = GameManager.level.world.CreateJoint(jointDef);
//				}
//			
//				if(bli > 0){
//					if(bodies[bli-1][blj] == null) continue;
//						var b1:b2Body=bodies[bli][blj];
//						var b2:b2Body=bodies[bli-1][blj];
//						var p1b1:b2Vec2 = b1.GetWorldCenter().Copy(); p1b1.Add(new b2Vec2(0,- GameLevel.FlashToBox(sbitmap.pieceW/2) ) );
//						var p1b2:b2Vec2 = b2.GetWorldCenter().Copy(); p1b2.Add(new b2Vec2(0,- GameLevel.FlashToBox(sbitmap.pieceW/2) ) );
//						var p2b1:b2Vec2 = b1.GetWorldCenter().Copy(); p2b1.Add(new b2Vec2(0,GameLevel.FlashToBox(sbitmap.pieceW/2) ) );
//						var p2b2:b2Vec2 = b2.GetWorldCenter().Copy(); p2b2.Add(new b2Vec2(0,GameLevel.FlashToBox(sbitmap.pieceW/2) ) );
//						
//						jointDef.Initialize(b1, b2, p1b1, p1b2);  
//						joint = GameManager.level.world.CreateJoint(jointDef);
//						jointDef.Initialize(b1, b2, p2b1, p2b2);
//						joint = GameManager.level.world.CreateJoint(jointDef);
//						jointDef.Initialize(b1, b2, b1.GetWorldCenter(), b2.GetWorldCenter());
//						joint = GameManager.level.world.CreateJoint(jointDef);
//					}
//				}	
//			}
			
			/*
			var jointDef : b2DistanceJointDef = new b2DistanceJointDef();
			jointDef.Initialize(bodies[0][0], bodies[sbitmap.totalX-1][sbitmap.totalY-1], bodies[0][0].GetWorldCenter(),  bodies[sbitmap.totalX-1][sbitmap.totalY-1].GetWorldCenter());
			//jointDef.body1 = bodies[bli][blj];
			
			//jointDef.body2 = bodies[bli-1][blj];
			jointDef.dampingRatio = damp;
			jointDef.frequencyHz = frequency;
			jointDef.collideConnected = collide;
			var joint:b2Joint = GameManager.level.world.CreateJoint(jointDef);
			*/
			/*
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
			*/
		}
		
		override public function Contact():void {
			super.Contact();
			
			if (body == null) return;
			if ( Math.abs(body.GetLinearVelocity().y) > 15) {
				//Break();
			}
			
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			if (numChildren > 0 ) return null;
			var bmd : BitmapData = new BitmapData(child.width, child.height, true, 0x000000);
			bmd.draw(child);
			
			var graphic : ShatterBitmap = new ShatterBitmap(bmd,3);
			
			return super.addChild(graphic);
		}
		
		public function Break():void{
			(getChildAt(0) as ShatterBitmap).Break();
			body.SetUserData("dead");
			body = null;
			
			for each(var p : MovieClip in (getChildAt(0) as ShatterBitmap).piecesArray) {
				GameManager.level.AddObjectToCreationQueue(p);
			}
		}

	}
}