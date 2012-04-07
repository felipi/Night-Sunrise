package System.Input
{
	import Graphics.FX.LightingEngine.LE;
	import Graphics.Scenes.LevelScene;
	
	import System.GameManager;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import uk.co.bigroom.input.KeyPoll;
	
	public class ActorInput extends GameInput
	{
		public static const WALK_RIGHT : String = "walkRight";
		public static const WALK_LEFT : String = "walkLeft";
		public static const CLIMB : String = "climb";
		public static const FALL : String = "fall";
		public static const IDLE : String = "idle";
		public static const JUMP : String = "jump";
		
		private var key : KeyPoll;
		private var spacePressed:Boolean = false;
		
		public function ActorInput()
		{
			key = new KeyPoll(GameManager.stage);
			
			GameManager.stage.addEventListener(KeyboardEvent.KEY_UP, Release);
			
			GameManager.stage.addEventListener(Event.ENTER_FRAME, Refresh);
			
			GameManager.stage.addEventListener(MouseEvent.CLICK, Click);
		}
		
		private function Refresh(k:Event): void {
			if(key.isDown(kRight)){
				dispatchEvent(new Event(WALK_RIGHT));
			}
			if(key.isDown(kLeft)){
				dispatchEvent(new Event(WALK_LEFT));
			}
			if(key.isDown(kUp)){
				dispatchEvent(new Event(CLIMB));
			}

			if(key.isDown(kButtonA) && !spacePressed){
				dispatchEvent(new Event(JUMP));
				spacePressed = true;
			}
			
			if (key.isUp(kButtonA)) {
				spacePressed = false;
			}
		}
		
		private function Release(k:KeyboardEvent): void {
			dispatchEvent(new Event(IDLE));
		}
		
		private function Click(me:MouseEvent) : void {
			if(typeof(GameManager.scene) != "LevelScene") return;
			LE.Trigger();
		}
		
	}
}