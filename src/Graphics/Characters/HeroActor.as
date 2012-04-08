package Graphics.Characters
{
	import Box2D.Common.Math.b2Vec2;

	public class HeroActor extends BaseActor
	{
		public function HeroActor(sheetName:String)
		{
			super(sheetName);
			
			//Actions registry
			registeredActions["CLIMB"] = Climb;
			registeredActions["JUMP"] = Jump;
			registeredActions["IDLE"] = Idle;
			registeredActions["WALK"] = Walk;
		}
		
		//Actions
		private function Idle(): void {
			currentState = "idle";
			speedx = 0;
		}
		
		private function Walk(walkRight:Boolean): void {
			currentState = "walk";
			facingRight = walkRight;
			
			var direction : Number = walkRight ? 1 : -1;
			speedx = direction * (animationSpeed/8);
		}
		
		private function Climb(): void {
			
		}
		
		private function Jump(): void {
			
			if (physicsActor == null || !canJump) return;
			
			jumpCount = jumpHeight;
			jumping = true;
			
			physicsActor.body.ApplyImpulse(new b2Vec2(0, jumpHeight * -100 ), physicsActor.body.GetLocalCenter());
		}
	}
}