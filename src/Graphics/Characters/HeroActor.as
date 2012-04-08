package Graphics.Characters
{
	import Box2D.Common.Math.b2Vec2;
	
	import System.GameManager;

	public class HeroActor extends BaseActor
	{
		public function HeroActor(sheetName:String)
		{
			super(sheetName);
			
			//Actions register
			RegisterAction("CLIMB", Climb);
			RegisterAction("JUMP", Jump);
			RegisterAction("IDLE", Idle);
			RegisterAction("WALK", Walk);
			RegisterAction("BLOCK", Block);
			
			//States register
			RegisterState("idle",  0, 0);
			RegisterState("walk", 10, 13);
			RegisterState("jump", 15, 15);
			RegisterState("fall", 14, 14);
			RegisterState("block", 20, 20);
			currentState = "idle";
		}
		
		public override function Update(): void {
			super.Update();
			
			if (physicsActor != null){
				physicsActor.body.WakeUp();
				physicsActor.body.m_linearVelocity.x = speedx;
				
				if (physicsActor.body.m_linearVelocity.y < 0 && !isColliding) {
					currentState = "jump";
				}
				if (physicsActor.body.m_linearVelocity.y > 0 && !isColliding) {
					currentState = "fall";
				}
			}
		}
		
		//Actions
		private function Idle(): void {
			currentState = "idle";
			speedx = 0;
			jumping = false;
		}
		
		private function Walk(walkRight:Boolean): void {
			if(currentState=="block") return;
			currentState = "walk";
			facingRight = walkRight;
			
			var direction : Number = walkRight ? 1 : -1;
			speedx = direction * (animationSpeed/8);
		}
		
		private function Climb(): void {
			
		}
		
		private function Block(): void {
			//if(!canJump) return;
			if(currentState=="jump" || currentState=="fall") return;
			currentState = "block";
			
			GameManager.DTrace("=====BLOCKING!!=====")
		}
		
		private function Jump(): void {
			
			if (physicsActor == null || !canJump) return;
			
			jumpCount = jumpHeight;
			jumping = true;
			
			physicsActor.body.ApplyImpulse(new b2Vec2(0, jumpHeight * -100 ), physicsActor.body.GetLocalCenter());
		}
	}
}